#!/bin/bash

set -u

if [ ! -f ./config.sh ]; then
    echo "config.sh not found"
    exit 1
fi

source ./config.sh

die() {
    echo "$*" 1>&2
    exit 1
}

validate_cluster() {
    echo "Validating cluster ${KOPS_CLUSTER_NAME}"
    kops validate cluster
    RV=$?

    return "${RV}"
}

set_tf_resource_name() {
    export TF_RESOURCE_NAME=$(echo ${KOPS_CLUSTER_NAME} | tr "." "-")
}

generate_cluster_autoscaler_tf() {
    set_tf_resource_name
    # we can now specify the exact ASG instead of "*" for the autoscaler policy
    # https://github.com/kubernetes/autoscaler/pull/527
    # https://docs.aws.amazon.com/autoscaling/latest/userguide/control-access-using-iam.html#policy-auto-scaling-resources
    cat <<BASHEOF > ./out/terraform/cluster_autoscaler.tf
# This file is generated via post-install.sh
resource "aws_iam_policy" "nodes-${TF_RESOURCE_NAME}-autoscaler-policy" {
    name        = "nodes-${TF_RESOURCE_NAME}-autoscaler-policy"
    path        = "/"
    description = "Policy for K8s AWS autoscaler"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "autoscaler-attach" {
    role       = "\${aws_iam_role.nodes-${TF_RESOURCE_NAME}.name}"
    policy_arn = "\${aws_iam_policy.nodes-${TF_RESOURCE_NAME}-autoscaler-policy.arn}"
}
BASHEOF

    DEFAULT_MAX=$(echo "$((4 * ${KOPS_NODE_COUNT}))")
    # set ASG max size so to allow the cluster autoscaler to scale up
    # retains whitespace for easier reading :-)
    echo "Editing kubernetes.tf to increase max_size"
    sed -ri "s/max_size(\s*)=(\s*)$KOPS_NODE_COUNT/max_size\\1=\2$DEFAULT_MAX/" ./out/terraform/kubernetes.tf
}

install_mig() {
    echo "Install mig"
    kubectl create -f "${KOPS_INSTALLER}/services/mig/mig-namespace.yaml"

    # Export mqpassword
    MQPASSWORD=$(cat ${SECRETS_PATH}/k8s/secrets/mig/mqpassword)
    ( cd ${KOPS_INSTALLER}/services/mig && make MQPASSWORD=${MQPASSWORD} )
    kubectl -n mig create secret generic mig-agent-secrets \
        --from-file=${SECRETS_PATH}/k8s/secrets/mig/agent.key \
        --from-file=${SECRETS_PATH}/k8s/secrets/mig/agent.crt \
        --from-file=${SECRETS_PATH}/k8s/secrets/mig/ca.crt \
        --from-file=${KOPS_INSTALLER}/services/mig/mig-agent.cfg
    kubectl -n mig create -f ${KOPS_INSTALLER}/services/mig/migdaemonset.yaml
    rm -f "${KOPS_INSTALLER}/services/mig/mig-agent.cfg"
    unset MQPASSWORD
}

install_newrelic() {
    echo "Installing New Relic"
    kubectl create -f "${KOPS_INSTALLER}/services/newrelic/newrelic-namespace.yaml"
    ( cd ${KOPS_INSTALLER}/services/newrelic && make CLUSTER_NAME=${KOPS_SHORTNAME} )
}

install_calico_rbac() {
    if [ ${KOPS_NETWORKING} != "calico" ]; then
        echo "Networking not using calico, not doing anything"
        continue
    else
        kubectl apply -f "https://docs.projectcalico.org/${CALICO_VERSION:-v3.2}/getting-started/kubernetes/installation/rbac.yaml"
    fi
}

install_fluentd() {
    echo "Installing fluentd"
    (cd ${KOPS_INSTALLER}/services/fluentd && make FLUENTD_SYSLOG_HOST=${SYSLOG_HOST} FLUENTD_SYSLOG_PORT=${SYSLOG_PORT})
}

install_redirector_service() {
    (cd ${KOPS_INSTALLER}/services/http_to_https_redirector && make deploy)
}

install_cluster_autoscaler() {
    MAX_NODES=20

    echo "Installing cluster autoscaler"
    # https://github.com/kubernetes/dashboard/issues/2326#issuecomment-326651713
    kubectl create clusterrolebinding \
        --user system:serviceaccount:kube-system:default \
        kube-system-cluster-admin --clusterrole cluster-admin
    (cd ${KOPS_INSTALLER}/services/cluster-autoscaler && make MAX_NODES=${MAX_NODES} KOPS_CLUSTER_NAME=${KOPS_CLUSTER_NAME} AWS_REGION=${KOPS_REGION})
}

install_datadog() {
    echo "Installing datadog"
    kubectl apply -f "${KOPS_INSTALLER}/services/datadog/datadog-namespace.yaml"
    kubectl apply -f "${KOPS_INSTALLER}/services/datadog/datadog_statsd_svc.yaml"
    kubectl apply -f "${KOPS_INSTALLER}/services/datadog/datadog-agent.yaml"
    kubectl apply -f "${SECRETS_PATH}/scm/mdn-k8s-private/k8s/secrets/datadog-cluster.yaml"
}

install_services() {
    install_cluster_autoscaler
    install_calico_rbac
    install_fluentd
    install_mig
    install_datadog
    install_redirector_service
}
