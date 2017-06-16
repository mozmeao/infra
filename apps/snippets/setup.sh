#!/bin/bash -e

if [ -z "$DEIS_PROFILE" ]; then
    echo "Please set DEIS_PROFILE"
    exit 1
fi


if [ -z "$KUBECONFIG" ]; then
    echo "Please set KUBECONFIG"
    exit 1
fi

wget https://raw.githubusercontent.com/mozmar/snippets-service/master/Procfile
deis create snippets-prod --no-remote
kubectl -n snippets-prod apply -f ./k8s/snippets-prod-nodeport.yaml

deis config:set ALLOWED_HOSTS=snippets-prod.frankfurt,snippets-prod.moz.works,snippets.cdn.mozilla.net,snippets-prod-cdn.moz.works,snippets.mozilla.com -a snippets-prod

deis pull mozorg/snippets:9973b1 -a snippets-prod



