#!/bin/bash

source ../common.sh

export KOPS_REGION="us-east-1"
export KOPS_CLUSTER="k8s.${KOPS_REGION}.${KOPS_DOMAIN}"

# Get this by running this command
# aws ec2 describe-availability-zones --region <REGION?
export KOPS_MASTER_ZONE="us-east-1a,us-east-1b,us-east-1c"
export KOPS_ZONE="us-east-1a,us-east-1b,us-east-1c"
