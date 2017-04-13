#!/bin/bash -e

export KUBECONFIG="/home/admin/ee-infra-private/k8s/clusters/virginia/virginia.kubeconfig"

# if the private repo is still locked, this will fail
if ! kubectl config current-context; then
    echo "Can't access k8s, is the repo still locked?"
    exit 1
fi

PATH_TO_MYSQL_SETTINGS="/home/admin/ee-infra-private/mdn/services/mysql/mdn-mm-mysql-values.yaml"
MM_NAMESPACE="mdn-mm"
CHART_INSTANCE_NAME="mdn-mm-mysql"

echo "Creating k8s namespace ${MM_NAMESPACE}"
kubectl create namespace "${MM_NAMESPACE}" || true

echo "Fetching mysql chart"
helm fetch stable/mysql --untar

echo "Patching chart to support mozmar/mdn-mysql"
sed -i "s#mysql:{{#quay.io/mozmar/mdn-mysql:{{#" mysql/templates/deployment.yaml

echo "Installing chart"
helm install \
    --name "${CHART_INSTANCE_NAME}" \
     ./mysql \
     --namespace "${MM_NAMESPACE}" \
     -f "${PATH_TO_MYSQL_SETTINGS}"
