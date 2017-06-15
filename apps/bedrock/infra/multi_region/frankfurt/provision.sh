#!/bin/bash -e

export TERRAFORM_ENV="frankfurt"
export BEDROCK_PROVISIONING_REGION="eu-central-1"

# Terraform env
export TF_VAR_region="${BEDROCK_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-10685f78,subnet-57ef9f2d"
export TF_VAR_vpc_id="vpc-4d036a25"
export TF_VAR_pgsql_identifier="bedrock"
export TF_VAR_pgsql_db_name="bedrock"
export TF_VAR_pgsql_username="bedrock"
# you'll be prompted for a password!

# Apply Terraform
cd ../tf && ./common.sh

