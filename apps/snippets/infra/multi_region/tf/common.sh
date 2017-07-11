#!/bin/bash

set -e


check_prereqs() {
    if [ -z "${SNIPPETS_REGION}" ]; then
        echo "SNIPPETS_REGION must be set"
        exit -1
    fi

    if [ -z "${KOPS_NAME}" ]; then
        echo "KOPS_NAME is unset, please set it or source config.sh"
        exit 1
    fi

    if [ -z "${TERRAFORM_ENV}" ]; then
        echo "TERRAFORM_ENV must be set"
        exit -1
    fi
}

SNIPPETS_TF_STATE_BUCKET="snippets-shared-tf-state"
STATE_BUCKET_REGION="us-west-2"

setup_tf_s3_state_store() {
    echo "Creating Terraform state bucket at s3://${SNIPPETS_TF_STATE_BUCKET} (region ${STATE_BUCKET_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${SNIPPETS_TF_STATE_BUCKET} --region ${STATE_BUCKET_REGION}
}

setup_tf_envs() {
    # this MUST be run in the dir that this file resides in
    set +e
    terraform env new tokyo
    terraform env new frankfurt
    set -e
}

check_state_store() {
    echo "Checking state store"
    set +e
    if aws s3 ls s3://${SNIPPETS_TF_STATE_BUCKET} > /dev/null 2>&1; then
        echo "State store already exists"
    else
        echo "Setting up state store"
        setup_tf_s3_state_store
    fi
    set -e
}

get_subnets() {
    QUERY=".Subnets[] | select(.Tags[]?.Value==\"$KOPS_NAME\") | .SubnetId"
    SUBNETS=$(aws ec2 describe-subnets --region $TF_VAR_region | jq -r "$QUERY" 2> /dev/null | sort)
    SUBNET_LIST=$(paste -d, -s - <<< "${SUBNETS}")
    echo "${SUBNET_LIST}"
}

get_k8s_nodes_security_group() {
    QUERY=".SecurityGroups[] | select(.GroupName == \"nodes.${KOPS_NAME}\") | .GroupId"
    SECURITY_GROUP=$(aws ec2 describe-security-groups --region $TF_VAR_region | jq -r "$QUERY")
    echo "${SECURITY_GROUP}"
}

import_tokyo() {
    terraform import aws_s3_bucket.logs-prod snippets-prod-tokyo-logs
    terraform import aws_s3_bucket.logs-stage snippets-stage-tokyo-logs
    terraform import module.redis.aws_elasticache_replication_group.shared-redis-rg shared-redis
    terraform import module.redis.aws_elasticache_subnet_group.shared-redis-subnet-group shared-redis-subnet-group
    terraform import module.bucket-prod.aws_s3_bucket.bundles snippets-prod-tokyo
    terraform import module.bucket-prod.aws_s3_bucket.logs snippets-prod-tokyo-logs
    terraform import module.bucket-stage.aws_s3_bucket.bundles snippets-stage-tokyo
    terraform import module.bucket-stage.aws_s3_bucket.logs snippets-stage-tokyo-logs
    terraform import module.prod-alerts.aws_route53_health_check.health_check 24452636-e643-47df-be55-ae45f79c7cb4
    terraform import module.stage-alerts.aws_route53_health_check.health_check 6501092d-c633-4dde-b016-189adb567b18
}


import_frankfurt() {
    terraform import aws_s3_bucket.logs-prod snippets-prod-frankfurt-logs
    terraform import aws_s3_bucket.logs-stage snippets-stage-frankfurt-logs
    terraform import module.redis.aws_elasticache_replication_group.shared-redis-rg shared-redis
    terraform import module.redis.aws_elasticache_subnet_group.shared-redis-subnet-group shared-redis-subnet-group
    terraform import module.bucket-prod.aws_s3_bucket.bundles snippets-prod-frankfurt
    terraform import module.bucket-prod.aws_s3_bucket.logs snippets-prod-frankfurt-logs
    terraform import module.bucket-stage.aws_s3_bucket.bundles snippets-stage-frankfurt
    terraform import module.bucket-stage.aws_s3_bucket.logs snippets-stage-frankfurt-logs
    terraform import module.prod-alerts.aws_route53_health_check.health_check 37e2e791-4710-46b1-94ea-4fdb8b71a77c
    terraform import module.stage-alerts.aws_route53_health_check.health_check 02c895c0-6333-4508-9978-e66d9f872f36
}



check_state_store

export TF_VAR_kops_name="${KOPS_NAME}"
export TF_VAR_cache_subnet_ids=$(get_subnets)
export TF_VAR_cache_security_group=$(get_k8s_nodes_security_group)

echo "Using the following subnets: ${TF_VAR_cache_subnet_ids}"
echo "Using the following security group: ${TF_VAR_cache_security_group}"

tf_main() {
    # it's safe to always init the s3 backend
    terraform init

    setup_tf_envs

    # switch env to virginia, tokyo etc
    terraform env select ${TERRAFORM_ENV}

    PLAN=$(mktemp)
    terraform plan --out $PLAN $TF_ARGS

    echo "Please verify plan output above and enter the command"
    echo "'make it so' followed by enter to continue."
    echo "Otherwise, Ctrl-C to abort"V
    read

    # if terraform plan fails, the next command won't run due to
    # set -e at the top of the script.
    terraform apply $PLAN
    rm $PLAN
}

check_prereqs
check_state_store
tf_main

#terraform get
#
#PLAN=$(mktemp)
#terraform plan --out $PLAN
## if terraform plan fails, the next command won't run due to
## set -e at the top of the script.
#terraform apply $PLAN
#rm $PLAN

