#!/bin/bash

set -e
set -u

SUMO_PROVISIONING_REGION="us-west-2"
TERRAFORM_ENV="sumo-shared"
SUMO_PROVISIONING_BUCKET="sumo-shared-provisioning-tf-state"
STATE_BUCKET_REGION="us-west-2"

setup_tf_s3_state_store() {
    echo "Creating Terraform state bucket at s3://${SUMO_PROVISIONING_BUCKET} (region ${STATE_BUCKET_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${SUMO_PROVISIONING_BUCKET} --region ${STATE_BUCKET_REGION}
}

setup_tf_envs() {
    # this MUST be run in the dir that this file resides in
    set +e
    terraform env new sumo-shared
    set -e
}

check_state_store() {
    echo "Checking state store"
    set +e
    if aws s3 ls s3://${SUMO_PROVISIONING_BUCKET} > /dev/null 2>&1; then
        echo "State store already exists"
    else
        echo "Setting up state store"
        setup_tf_s3_state_store
        echo "Setting up envs"
        setup_tf_envs
    fi
    set -e
}

banner() {
    echo "   _____ _    _ __  __  ____    _____        __           ";
    echo "  / ____| |  | |  \/  |/ __ \  |_   _|      / _|          ";
    echo " | (___ | |  | | \  / | |  | |   | |  _ __ | |_ _ __ __ _ ";
    echo "  \___ \| |  | | |\/| | |  | |   | | | '_ \|  _| '__/ _\` |";
    echo "  ____) | |__| | |  | | |__| |  _| |_| | | | | | | | (_| |";
    echo " |_____/ \____/|_|  |_|\____/  |_____|_| |_|_| |_|  \__,_|";
    echo "                                                          ";
    echo "                                                          ";
}

tf_main() {
    
    # it's safe to always init the s3 backend
    terraform init

    setup_tf_envs

    # switch env to virginia, tokyo etc
    terraform env select ${TERRAFORM_ENV}

    # import local modules
    terraform get

    PLAN=$(mktemp)
    terraform plan --out $PLAN

    echo "Please verify plan output above and enter the command"
    echo "'make it so' followed by enter to continue."
    echo "Otherwise, Ctrl-C to abort"V
    read

    # if terraform plan fails, the next command won't run due to
    # set -e at the top of the script.
    terraform apply $PLAN
    rm $PLAN
}

banner
check_state_store
tf_main


