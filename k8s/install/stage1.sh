#!/bin/bash
set -e
echo -n "Starting @"
date
echo -n "Work directory: "
pwd
if [ -f config.sh ]; then
    echo "Sourcing config.sh"
    source config.sh
else
    echo "Can't find config.sh in cwd"
    exit -1
fi


if [ -z "${KOPS_INSTALLER}" ]; then
    echo "KOPS_INSTALLER must be set to the infra/k8s/install directory"
    exit -1
fi

# see if a var is defined
check_var() {
    echo -n "$1 = "
    v=$(eval echo "\$$1")
    if [ -z "$v" ]; then
        echo "NOT DEFINED"
        exit -1
    else
        echo "$v"
    fi
}

verify_env() {
    required_vars=( KOPS_SHORT_NAME KOPS_DOMAIN KOPS_NAME KOPS_REGION KOPS_STATE_STORE
                    KOPS_NODE_COUNT KOPS_NODE_SIZE KOPS_MASTER_SIZE KOPS_PUBLIC_KEY
                    KOPS_ZONES KOPS_MASTER_ZONES )
    echo ""
    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    echo "Environment"
    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    for v in "${required_vars[@]}"
    do
        check_var $v
    done

    export TF_RESOURCE_NAME=$(echo ${KOPS_NAME} | tr "." "-")
    IFS=',' read -ra AZ_LIST <<< ${KOPS_ZONES}
    ZONE_COUNT="${#AZ_LIST[@]}"

    export KOPS_AZ0="${AZ_LIST[0]}"
    export KOPS_AZ1="${AZ_LIST[1]}"
    export KOPS_AZ2="${AZ_LIST[2]}"

    echo "TF_RESOURCE_NAME=${TF_RESOURCE_NAME}"
    echo "ZONE_COUNT=${ZONE_COUNT}"
    echo "KOPS_AZ0=${KOPS_AZ0}"
    echo "KOPS_AZ1=${KOPS_AZ1}"
    echo "KOPS_AZ2=${KOPS_AZ2}"
    echo "All vars set"
    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    echo ""
}

run_kops() {
    kops create cluster ${KOPS_NAME} \
        --zones=${KOPS_ZONES} \
        --master-zones=${KOPS_MASTER_ZONES} \
        --target=terraform \
        --node-count=${KOPS_NODE_COUNT} \
        --node-size=${KOPS_NODE_SIZE} \
        --master-size=${KOPS_MASTER_SIZE} \
        --ssh-public-key=${KOPS_PUBLIC_KEY}
}

render_tf_templates() {
    # https://github.com/hashicorp/terraform/issues/4084
    # we use sed here to generate Terraform files from "templates"
    # if we need more than 3 vars, consider a different approach.
    # Generate a terraform file for creating s3 buckets for Deis
    cat ${KOPS_INSTALLER}/etc/deis_s3.tf.template \
        | sed s/KOPS_REGION/${KOPS_REGION}/g \
        | sed s/TF_RESOURCE_NAME/${TF_RESOURCE_NAME}/g \
        | sed s/KOPS_NAME/${KOPS_NAME}/g \
        > ./out/terraform/deis_s3.tf

    if [ -z "${KOPS_EXISTING_RDS}" ]
    then
        echo "Creating new RDS instance"
        # generate a terraform file to create an RDS instance

        cat ${KOPS_INSTALLER}/etc/deis_rds.tf.template \
            | sed s/TF_RESOURCE_NAME/${TF_RESOURCE_NAME}/g \
            | sed s/KOPS_NAME/${KOPS_NAME}/g \
            | sed s/KOPS_AZ0/${KOPS_AZ0}/g \
            | sed s/KOPS_AZ1/${KOPS_AZ1}/g \
            | sed s/KOPS_AZ2/${KOPS_AZ2}/g \
            > ./out/terraform/deis_rds.tf

        # generate a terraform file with RDS instance variables
        cat ${KOPS_INSTALLER}/etc/deis_rds_variables.tf.template \
            | sed s/TF_RESOURCE_NAME/${TF_RESOURCE_NAME}/g \
            > ./out/terraform/deis_rds_variables.tf
    else
        echo "Using existing RDS instance"
    fi
}

setup_tf_s3_state_store() {
    cd out/terraform
    echo "Creating Terraform state bucket at s3://${TF_STATE_BUCKET} (region ${KOPS_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${TF_STATE_BUCKET} --region ${KOPS_REGION}

    echo "Configuring Terraform to use an encrypted remote S3 bucket for state storage"
    # store TF state in S3
    terraform remote config \
        -backend=s3 \
        -backend-config="bucket=${TF_STATE_BUCKET}" \
        -backend-config="key=${KOPS_SHORT_NAME}/terraform.tfstate" \
        -backend-config="encrypt=1" \
        -backend-config="region=${KOPS_REGION}"
    echo "Encryption for TF state:"
    aws s3api head-object --bucket=$TF_STATE_BUCKET --key=${KOPS_SHORT_NAME}/terraform.tfstate | jq -r .ServerSideEncryption
}

verify_env
run_kops
render_tf_templates
setup_tf_s3_state_store

echo ""
echo "To finish the installation of K8s:"
echo "cd out/terraform"
echo "terraform plan"
echo "terraform apply"
echo -n "Finished @"
date