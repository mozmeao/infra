#!/bin/bash -e

export TERRAFORM_ENV="portland"
export MDN_PROVISIONING_REGION="us-west-2"
export TF_VAR_region="${MDN_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-1349a175,subnet-3c8c8e75"
# nodes.portland.moz.works
export TF_VAR_nodes_security_group="sg-673bb51d"

# Apply Terraform
cd ../tf && ./common.sh

