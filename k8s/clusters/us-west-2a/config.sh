#!/bin/bash

source ../common.sh

export KOPS_REGION="us-west-2"
export KOPS_CLUSTER="k8s.${KOPS_REGION}a.${KOPS_DOMAIN}"

export KOPS_MASTER_ZONE="us-west-2a"
export KOPS_MASTER_COUNT=1
export KOPS_ZONE="us-west-2a"
export KOPS_NODE_COUNT="3"
