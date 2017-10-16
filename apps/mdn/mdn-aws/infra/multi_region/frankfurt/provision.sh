#!/bin/bash -e

export TERRAFORM_ENV="frankfurt"
export MDN_PROVISIONING_REGION="eu-central-1"
export TF_VAR_region="${MDN_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-10685f78,subnet-10685f78"
# nodes.frankfurt.moz.works
export TF_VAR_nodes_security_group="sg-e73a4e8c"
export TF_VAR_vpc_id="vpc-4d036a25"
export TF_VAR_vpc_cidr="172.20.0.0/16"

# Apply Terraform
# NOTE! since Frankfurt uses an RDS read replica and will only host prod resources,
#       we call out each resource below via -target=...
cd ../tf && ./common.sh -target=module.efs-prod -target=module.redis-prod -target=module.memcached-prod


