#!/bin/bash -e

: ${HELM_RELEASE_NAME:=$(helm list | grep workflow | awk '{ print $1 }')}
source ./stage2_functions.sh

customize_workflow
echo "Upgrade ${HELM_RELEASE_NAME}? (ctrl-c to abort, set HELM_RELEASE_NAME env var to override)"
read
helm upgrade -f workflow_config_moz.yaml "${HELM_RELEASE_NAME}" ./workflow
echo "Done."
