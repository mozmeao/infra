#!/bin/bash -e
HELM_VERSION=v2.1.3
if [ -z "${KOPS_INSTALLER}" ]; then
    echo "KOPS_INSTALLER must be set to the infra/k8s/install directory"
    exit -1
fi

if [ -z "${STAGE2_ETC_PATH}" ]; then
	echo "STAGE2_ETC_PATH must be set"
	exit -1
fi

# let's make sure we are in the right directory
terraform output region > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo "Please run from <mycluster>/out/terraform directory"
	exit 1
fi

source ${KOPS_INSTALLER}/stage2_functions.sh

install_deps
install_tiller

# k8s specific
if [ "${INSTALL_DASHBOARD}" -eq 1 ]; then install_k8s_dashboard; fi
if [ "${INSTALL_HEAPSTER}" -eq 1 ]; then install_heapster; fi

# MozMEAO monitoring
if [ "${INSTALL_MIG}" -eq 1 ]; then install_mig; fi
if [ "${INSTALL_DATADOG}" -eq 1 ]; then install_dd; fi
if [ "${INSTALL_NEWRELIC}" -eq 1 ]; then install_newrelic; fi
if [ "${INSTALL_FLUENTD}" -eq 1 ]; then install_fluentd; fi

if [ "${INSTALL_WORKFLOW}" -eq 1 ]; then
    install_workflow
    config_deis_elb
    config_deis_dns
fi


