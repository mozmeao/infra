#!/bin/bash -e

export TERRAFORM_ENV="virginia"
export BEDROCK_PROVISIONING_REGION="us-east-1"

# Terraform env
export TF_VAR_region="${BEDROCK_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-43125f6e,subnet-a699aaef,subnet-b6ceb6ed"
export TF_VAR_vpc_id="vpc-1b35a07d"
export TF_VAR_pgsql_identifier="bedrock"
export TF_VAR_pgsql_db_name="bedrock"
export TF_VAR_pgsql_username="bedrock"
# you'll be prompted for a password!

# Apply Terraform
cd ../tf && ./common.sh

