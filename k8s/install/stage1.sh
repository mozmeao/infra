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

source ${KOPS_INSTALLER}/stage1_functions.sh

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
