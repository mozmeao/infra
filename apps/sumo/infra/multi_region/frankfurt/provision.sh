#!/bin/bash -e

export TERRAFORM_ENV="frankfurt"
export SUMO_PROVISIONING_REGION="eu-central-1"
export TF_VAR_region="${SUMO_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-10685f78,subnet-57ef9f2d"
# nodes.frankfurt.moz.works
export TF_VAR_nodes_security_group="sg-e73a4e8c"
export TF_VAR_vpc_id="vpc-4d036a25"
export TF_VAR_vpc_cidr="172.20.0.0/16"

# Apply Terraform
cd ../tf && ./common.sh


