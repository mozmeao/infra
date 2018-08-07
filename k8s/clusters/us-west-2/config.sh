#!/bin/bash

source ../common.sh

export KOPS_REGION="us-west-2"
export KOPS_CLUSTER="k8s.${KOPS_REGION}.${KOPS_DOMAIN}"

export KOPS_MASTER_ZONE="us-west-2a,us-west-2b,us-west-2c"
export KOPS_ZONE="us-west-2a,us-west-2b,us-west-2c"
