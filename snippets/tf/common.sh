#!/bin/bash

set -e

if [ -z "${SNIPPETS_REGION}" ]; then
  echo "SNIPPETS_REGION must be set"
  exit -1
fi

if [ -z "${KOPS_NAME}" ]; then
  echo "KOPS_NAME is unset, please set it or source config.sh"
  exit 1
fi


SNIPPETS_TF_STATE_BUCKET="snippets-shared-tf-state"
STATE_BUCKET_REGION="us-west-2"

setup_tf_s3_state_store() {
    echo "Creating Terraform state bucket at s3://${SNIPPETS_TF_STATE_BUCKET} (region ${STATE_BUCKET_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${SNIPPETS_TF_STATE_BUCKET} --region ${STATE_BUCKET_REGION}

    echo "Configuring Terraform to use an encrypted remote S3 bucket for state storage"
    # store TF state in S3
    terraform remote config \
        -backend=s3 \
        -backend-config="bucket=${SNIPPETS_TF_STATE_BUCKET}" \
        -backend-config="key=snippets-${SNIPPETS_REGION}/terraform.tfstate" \
        -backend-config="encrypt=1" \
        -backend-config="region=${STATE_BUCKET_REGION}"

    echo "Encryption for TF state:"
    aws s3api head-object --bucket=$SNIPPETS_TF_STATE_BUCKET --key="snippets-${SNIPPETS_REGION}/terraform.tfstate" | jq -r .ServerSideEncryption
}

check_state_store() {
    echo "Checking state store"
    if aws s3 ls s3://${SNIPPETS_TF_STATE_BUCKET} > /dev/null 2>&1; then
        echo "State store already exists"
    else
        echo "Setting up state store"
        setup_tf_s3_state_store
    fi
}

get_subnets() {
    QUERY=".Subnets[] | select(.Tags[]?.Value==\"$KOPS_NAME\") | .SubnetId"
    SUBNETS=$(aws ec2 describe-subnets --region $TF_VAR_region | jq -r "$QUERY" 2> /dev/null | sort)
    SUBNET_LIST=$(paste -d, -s - <<< "${SUBNETS}")
    echo "${SUBNET_LIST}"
}

check_state_store

export TF_VAR_kops_name="${KOPS_NAME}"
export TF_VAR_cache_subnet_ids=$(get_subnets)

terraform get

PLAN=$(mktemp)
terraform plan --out $PLAN
# if terraform plan fails, the next command won't run due to
# set -e at the top of the script.
terraform apply $PLAN
rm $PLAN

