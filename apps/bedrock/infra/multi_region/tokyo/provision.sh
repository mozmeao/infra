#!/bin/bash -e

export TERRAFORM_ENV="tokyo"
export BEDROCK_PROVISIONING_REGION="ap-northeast-1"

# Terraform env
export TF_VAR_region="${BEDROCK_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-115ed549,subnet-ed79369b"
export TF_VAR_vpc_id="vpc-cd1f99a9"
export TF_VAR_pgsql_identifier="bedrock"
export TF_VAR_pgsql_db_name="bedrock"
export TF_VAR_pgsql_username="bedrock"
# you'll be prompted for a password!

# Apply Terraform
cd ../tf && ./common.sh

