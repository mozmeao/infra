#!/bin/bash

set -e
set -u

check_prereqs() {
    if [ -z "${ELB_PROVISIONING_REGION}" ]; then
    echo "ELB_PROVISIONING_REGION must be set"
    exit -1
    fi


    if [ -z "${TERRAFORM_ENV}" ]; then
    echo "TERRAFORM_ENV must be set"
    exit -1
    fi
}

TF_ARGS=$@

ELB_PROVISIONING_BUCKET="elb-provisioning-tf-state"
STATE_BUCKET_REGION="us-west-2"

get_elb_access_group_id() {
    aws ec2 describe-security-groups --region ${TF_VAR_region} | \
        jq -er '.SecurityGroups[] | select(.GroupName == "elb_access") | .GroupId'
}

check_k8s_context() {
  current=$(kubectl config current-context)
  if [ "${current}" != "${KOPS_NAME}" ]; then
    echo "Please select the appropriate kubeconfig"
    exit 1
  fi
}

setup_tf_s3_state_store() {
    echo "Creating Terraform state bucket at s3://${ELB_PROVISIONING_BUCKET} (region ${STATE_BUCKET_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${ELB_PROVISIONING_BUCKET} --region ${STATE_BUCKET_REGION}
}

setup_tf_envs() {
    # this MUST be run in the dir that this file resides in
    set +e
    terraform env new tokyo
    terraform env new virginia
    terraform env new frankfurt
    set -e
}

check_state_store() {
    echo "Checking state store"
    set +e
    if aws s3 ls s3://${ELB_PROVISIONING_BUCKET} > /dev/null 2>&1; then
        echo "State store already exists"
    else
        echo "Setting up state store"
        setup_tf_s3_state_store
        echo "Setting up envs"
        setup_tf_envs
    fi
    set -e
}

# utils for reimporing resources
#tf_repair() {
    #### repairing TF state
    #terraform refresh $TF_ARGS
    #
    # virginia
    #terraform import module.careers.aws_elb.new-elb careers
    #terraform import module.snippets.aws_elb.new-elb snippets

    # tokyo
    #terraform import module.careers.aws_elb.new-elb careers
    #terraform import module.snippets.aws_elb.new-elb snippets
    #### end repairing TF state
#}

tf_main() {
    # it's safe to always init the s3 backend
    terraform init

    setup_tf_envs

    # get the id of the elb_access security group that's
    # created as part of the meao k8s install
    export TF_VAR_elb_access_id=$(get_elb_access_group_id)

    # switch env to virginia, tokyo etc
    terraform env select ${TERRAFORM_ENV}

    # import local modules
    terraform get

    PLAN=$(mktemp)
    terraform plan --out $PLAN $TF_ARGS

    echo "Please verify plan output above and enter the command"
    echo "'make it so' followed by enter to continue."
    echo "Otherwise, Ctrl-C to abort"
    read

    # if terraform plan fails, the next command won't run due to
    # set -e at the top of the script.
    terraform apply $PLAN
    rm $PLAN
}

check_prereqs

check_k8s_context
check_state_store
tf_main


