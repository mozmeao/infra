#!/bin/bash

set -e
set -u

if [ -z "${KOPS_NAME}" ]; then
  echo "KOPS_NAME must be set"
  exit -1
fi

if [ -z "${TF_VAR_region}" ]; then
  echo "TF_VAR_region must be set"
  exit -1
fi

get_worker_nodes() {
    NODES_ASG="nodes.${KOPS_NAME}"
    QUERY=".AutoScalingGroups[] | select(.AutoScalingGroupName == \"${NODES_ASG}\") | .Instances[].InstanceId"
    INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups --region $TF_VAR_region | jq -r "${QUERY}")
    # I spent too long debugging a redirection bug here, so we have echo :-)
    INSTANCE_ID_LIST=$(echo "${INSTANCE_IDS}" | paste -d, -s -)
    echo "${INSTANCE_ID_LIST}"
}

get_http_nodeport() {
    NAMESPACE=$1
    NODEPORT_SERVICE=$2
    get_nodeport "http" $NAMESPACE $NODEPORT_SERVICE
}

get_https_nodeport() {
    NAMESPACE=$1
    NODEPORT_SERVICE=$2
    get_nodeport "https" $NAMESPACE $NODEPORT_SERVICE
}

get_nodeport() {
    PROTO=$1
    NAMESPACE=$2
    NODEPORT_SERVICE=$3
    kubectl -n ${NAMESPACE} get service ${NODEPORT_SERVICE} -o json \
        | jq ".spec.ports[] | select(.name == \"${PROTO}\") | .nodePort"
}

gen_tf_elb_cfg() {
    ELB_NAME=$1
    NAMESPACE=$2
    NODEPORT_SERVICE=$3
    VPC_SUBNETS=$4
    SSL_CERT_ID=$5

    K8S_NODE_INSTANCE_IDS=$(get_worker_nodes)
    HTTP_PORT=$(get_http_nodeport ${NAMESPACE} ${NODEPORT_SERVICE})
    HTTPS_PORT=$(get_https_nodeport ${NAMESPACE} ${NODEPORT_SERVICE})

    cat <<EOF
${ELB_NAME}_elb_name = "${ELB_NAME}"
${ELB_NAME}_subnets = "${VPC_SUBNETS}"
${ELB_NAME}_instances = "${K8S_NODE_INSTANCE_IDS}"
${ELB_NAME}_http_listener_instance_port = ${HTTP_PORT}
${ELB_NAME}_https_listener_instance_port = ${HTTPS_PORT}
${ELB_NAME}_ssl_cert_id = "${SSL_CERT_ID}"
EOF
}


