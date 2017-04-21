#!/bin/bash -e

export TERRAFORM_ENV="virginia"
export MDN_PROVISIONING_REGION="us-east-1"
export TF_VAR_region="${MDN_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-43125f6e,subnet-a699aaef,subnet-b6ceb6ed"

#export KOPS_NAME="virginia.moz.works"
#export TF_VAR_vpc_id="vpc-1b35a07d"

# Apply Terraform
cd ../tf && ./common.sh
# -var-file $SNIPPETS_VARFILE \

