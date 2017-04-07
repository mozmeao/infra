#!/bin/bash

set -e
set -u

if [ -z "${ELB_PROVISIONING_REGION}" ]; then
  echo "ELB_PROVISIONING_REGION must be set"
  exit -1
fi

TF_ARGS=$@

ELB_PROVISIONING_BUCKET="elb-provisioning-tf-state"
STATE_BUCKET_REGION="us-west-2"

setup_tf_s3_state_store() {
    echo "Creating Terraform state bucket at s3://${ELB_PROVISIONING_BUCKET} (region ${STATE_BUCKET_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${ELB_PROVISIONING_BUCKET} --region ${STATE_BUCKET_REGION}

    echo "Configuring Terraform to use an encrypted remote S3 bucket for state storage"
    # store TF state in S3
    terraform remote config \
        -backend=s3 \
        -backend-config="bucket=${ELB_PROVISIONING_BUCKET}" \
        -backend-config="key=elb-provisioning-${ELB_PROVISIONING_REGION}/terraform.tfstate" \
        -backend-config="encrypt=1" \
        -backend-config="region=${STATE_BUCKET_REGION}"

    echo "Encryption for TF state:"
    aws s3api head-object --bucket=$ELB_PROVISIONING_BUCKET --key="elb-provisioning-${ELB_PROVISIONING_REGION}/terraform.tfstate" | jq -r .ServerSideEncryption
}

check_state_store() {
    echo "Checking state store"
    set +e
    if aws s3 ls s3://${ELB_PROVISIONING_BUCKET} > /dev/null 2>&1; then
        echo "State store already exists"
    else
        echo "Setting up state store"
        setup_tf_s3_state_store
    fi
    set -e
}

check_state_store

terraform get

PLAN=$(mktemp)
terraform plan --out $PLAN $TF_ARGS
# if terraform plan fails, the next command won't run due to
# set -e at the top of the script.
terraform apply $PLAN
rm $PLAN

