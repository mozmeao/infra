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

get_redirector_port() {
    kubectl -n redirector get service redirector -o json \
        | jq ".spec.ports[] | select(.name == \"http\") | .nodePort"
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

    HTTP_PORT=$(get_redirector_port)
    HTTPS_PORT=$(get_https_nodeport ${NAMESPACE} ${NODEPORT_SERVICE})

    cat <<EOF
${ELB_NAME}_elb_name = "${ELB_NAME}"
${ELB_NAME}_subnets = "${VPC_SUBNETS}"
${ELB_NAME}_http_listener_instance_port = ${HTTP_PORT}
${ELB_NAME}_https_listener_instance_port = ${HTTPS_PORT}
${ELB_NAME}_ssl_cert_id = "${SSL_CERT_ID}"
EOF
}

attach_nodeport_sg_to_nodes_sg() {
    echo "Attaching nodeport security group to nodes sg"
    NODES_SECURITY_GROUP_NAME="nodes.${KOPS_NAME}"
    NODEPORT_SECURITY_GROUP_ID=$(cd ../tf && terraform output elb_security_group_id)
    NODES_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --region ${TF_VAR_region} \
        | jq -r ".SecurityGroups[] | select(.GroupName==\"${NODES_SECURITY_GROUP_NAME}\") | .GroupId")

    echo "Security group id = ${NODEPORT_SECURITY_GROUP_ID}"
    echo "Nodes security group id = ${NODES_SECURITY_GROUP_ID}"
    aws ec2 authorize-security-group-ingress \
        --source-group "${NODEPORT_SECURITY_GROUP_ID}" \
        --group-id "${NODES_SECURITY_GROUP_ID}" \
        --protocol "all" \
        --port -1 \
        --region "${TF_VAR_region}"
}
