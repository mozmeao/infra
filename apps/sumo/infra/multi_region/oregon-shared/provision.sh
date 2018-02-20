#!/bin/bash -e

export TERRAFORM_ENV="oregon-shared"
export SUMO_PROVISIONING_REGION="us-west-2"
export TF_VAR_region="${SUMO_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-0d89cd37ecec22dd2,subnet-e290afaa"

# NOTE: the var has been renamed from 
#       TF_VAR_nodes_security_group to TF_VAR_nodes_security_groups
export TF_VAR_nodes_security_groups="sg-0dcc6b0cbd3ad2322,sg-68868814"
export TF_VAR_vpc_id="vpc-ea93e58f"
export TF_VAR_vpc_cidr="10.0.0.0/16"

# Apply Terraform
# NOTE: we're only creating the mysql-prod resource in this region
cd ../tf && ./common.sh -target=module.mysql-prod