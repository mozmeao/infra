#!/bin/bash -e

export TERRAFORM_ENV="tokyo"
export MDN_PROVISIONING_REGION="ap-northeast-1"
export TF_VAR_region="${MDN_PROVISIONING_REGION}"
export TF_VAR_subnets="subnet-ed79369b,subnet-115ed549"

cd ../tf && ./common.sh

