#!/bin/bash -e

if [ -z "$DEIS_PROFILE" ]; then
    echo "Please set DEIS_PROFILE"
    exit 1
fi


if [ -z "$KUBECONFIG" ]; then
    echo "Please set KUBECONFIG"
    exit 1
fi

deis create snippets-stats --no-remote
deis pull mozmeao/snippets-stats:37727e -a snippets-stats
deis config:set ALLOWED_HOSTS=\* -a snippets-stats
kubectl -n snippets-stats apply -f ./snippets-stats-prod-nodeport.yaml
