#!/bin/bash -e

: ${HELM_RELEASE_NAME:=$(helm list | grep workflow | awk '{ print $1 }')}
: ${WORKFLOW_VALUES:="$1"}

if [[ -z $WORKFLOW_VALUES ]]; then
    echo WORKFLOW_VALUES path required as first arg or env var
    exit 1
fi
source ./stage2_functions.sh

customize_workflow
echo "Upgrade ${HELM_RELEASE_NAME} using ${WORKFLOW_VALUES}? (ctrl-c to abort; set HELM_RELEASE_NAME env var to override)"
read
helm upgrade -f "${WORKFLOW_VALUES}" "${HELM_RELEASE_NAME}" ./workflow
echo "Done."
