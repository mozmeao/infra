#!/bin/bash

source ../common.sh

export KOPS_REGION="eu-central-1"
export KOPS_SHORTNAME="k8s.${KOPS_REGION}a"
export KOPS_CLUSTER="k8s.${KOPS_REGION}a.${KOPS_DOMAIN}"
export KOPS_CLUSTER_NAME="${KOPS_CLUSTER}"

export KOPS_MASTER_ZONE="eu-central-1a"
export KOPS_MASTER_COUNT=1
export KOPS_ZONE="eu-central-1a"
export KOPS_NODE_COUNT="3"

# This is the path of of your services manifests
export KOPS_INSTALLER="../../install"

# secrets path
export SECRETS_PATH="${HOME}/scm/mdn-k8s-private"
export KOPS_SSH_PUB_KEY="${SECRETS_PATH}/ssh/mdn.key.pub"
