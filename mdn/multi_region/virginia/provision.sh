#!/bin/bash -e

export TERRAFORM_ENV="virginia"
export MDN_PROVISIONING_REGION="us-east-1"
export TF_VAR_region="${MDN_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-43125f6e,subnet-a699aaef,subnet-b6ceb6ed"

# Apply Terraform
cd ../tf && ./common.sh

