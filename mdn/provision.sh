#!/bin/bash

set -e

# NOTE: This variable MUST match the `region` variable in variables.tf
MDN_REGION="us-west-2"
MDN_TF_STATE_BUCKET="mdn-tf-state"

setup_tf_s3_state_store() {
    echo "Creating Terraform state bucket at s3://${MDN_TF_STATE_BUCKET} (region ${MDN_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${MDN_TF_STATE_BUCKET} --region ${MDN_REGION}

    echo "Configuring Terraform to use an encrypted remote S3 bucket for state storage"
    # store TF state in S3
    terraform remote config \
        -backend=s3 \
        -backend-config="bucket=${MDN_TF_STATE_BUCKET}" \
        -backend-config="key=mdn-${MDN_REGION}/terraform.tfstate" \
        -backend-config="encrypt=1" \
        -backend-config="region=${MDN_REGION}"

    echo "Encryption for TF state:"
    aws s3api head-object --bucket=$MDN_TF_STATE_BUCKET --key="mdn-${MDN_REGION}/terraform.tfstate" | jq -r .ServerSideEncryption
}

echo "Checking state store"
if aws s3 ls s3://${MDN_TF_STATE_BUCKET} > /dev/null 2>&1; then
    echo "State store already exists"
else
    echo "Setting up state store"
    setup_tf_s3_state_store
fi

echo "Importing mdn-downloads bucket if not present in state"
terraform import aws_s3_bucket.mdn-downloads mdn-downloads > /dev/null 2>&1 || true

terraform plan
# if terraform plan fails, the next command won't run due to
# set -e at the top of the script.
terraform apply
