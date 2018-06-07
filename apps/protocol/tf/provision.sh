#!/bin/bash

set -e
set -u

PROTOCOL_PROVISIONING_REGION="us-west-2"
TERRAFORM_ENV="protocol"
PROTOCOL_PROVISIONING_BUCKET="protocol-provisioning-tf-state"
STATE_BUCKET_REGION="us-west-2"

setup_tf_s3_state_store() {
    echo "Creating Terraform state bucket at s3://${PROTOCOL_PROVISIONING_BUCKET} (region ${STATE_BUCKET_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${PROTOCOL_PROVISIONING_BUCKET} --region ${STATE_BUCKET_REGION}
}

check_state_store() {
    echo "Checking state store"
    set +e
    if aws s3 ls s3://${PROTOCOL_PROVISIONING_BUCKET} > /dev/null 2>&1; then
        echo "State store already exists"
    else
        echo "Setting up state store"
        setup_tf_s3_state_store
    fi
    set -e
}

tf_main() {
    # it's safe to always init the s3 backend
    terraform init

    # import local modules
    terraform get

    PLAN=$(mktemp)
    terraform plan --out $PLAN


    echo "Please verify plan output above and enter the command"
    echo "'make it so' followed by enter to continue."
    echo "Otherwise, Ctrl-C to abort"
    read

    # if terraform plan fails, the next command won't run due to
    # set -e at the top of the script.
    terraform apply $PLAN
    rm $PLAN
}

check_state_store
tf_main


