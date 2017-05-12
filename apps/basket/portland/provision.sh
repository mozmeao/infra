#!/bin/bash -e

export TERRAFORM_ENV="portland"
export BASKET_PROVISIONING_REGION="us-west-2"

# Terraform env
export TF_VAR_region="${BASKET_PROVISIONING_REGION}"

if [[ -z $TF_VAR_fxa_dev_account ]]; then
    echo "Please set the TF_VAR_fxa_dev_account value as specified in:"
    echo "https://bugzilla.mozilla.org/show_bug.cgi?id=1358123#c18"
    exit 1
fi

if [[ -z $TF_VAR_fxa_stage_account ]]; then
    echo "Please set the TF_VAR_fxa_stage_account value as specified in:"
    echo "https://bugzilla.mozilla.org/show_bug.cgi?id=1358123#c18"
    exit 1
fi

if [[ -z $TF_VAR_fxa_prod_account ]]; then
    echo "Please set the TF_VAR_fxa_prod_account value as specified in:"
    echo "https://bugzilla.mozilla.org/show_bug.cgi?id=1358123#c18"
    exit 1
fi

# Apply Terraform
cd ../tf && ./common.sh

