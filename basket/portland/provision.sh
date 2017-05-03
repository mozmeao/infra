#!/bin/bash -e

export TERRAFORM_ENV="portland"
export BASKET_PROVISIONING_REGION="us-west-2"

# Terraform env
export TF_VAR_region="${BASKET_PROVISIONING_REGION}"

# Apply Terraform
cd ../tf && ./common.sh

