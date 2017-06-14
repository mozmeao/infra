#!/bin/bash -e

if [ -z "$DEIS_PROFILE" ]; then
    echo "Please set DEIS_PROFILE"
    exit 1
fi


if [ -z "$KUBECONFIG" ]; then
    echo "Please set KUBECONFIG"
    exit 1
fi

deis create nucleus-dev --no-remote
deis create nucleus-prod --no-remote

deis pull quay.io/mozmar/nucleus:3a4dbfe489cc1674742068b38735551711d013e5 -a nucleus-dev
deis pull quay.io/mozmar/nucleus:3a4dbfe489cc1674742068b38735551711d013e5 -a nucleus-prod

deis limits:set web=150M/300M -a nucleus-dev
deis limits:set web=100m/250m --cpu -a nucleus-dev
deis autoscale:set web --min=3 --max=5 --cpu-percent=80 -a nucleus-dev

deis limits:set web=150M/300M -a nucleus-prod
deis limits:set web=100m/250m --cpu -a nucleus-prod
deis autoscale:set cmd --min=3 --max=5 --cpu-percent=80 -a nucleus-prod

deis config:unset SECURE_SSL_REDIRECT -a nucleus-dev | true
deis config:unset SECURE_SSL_REDIRECT -a nucleus-prod | true

deis config:set  SSL_DISABLE=True -a nucleus-dev
deis config:set  SSL_DISABLE=True -a nucleus-prod

deis config:set ALLOWED_HOSTS=\* -a nucleus-dev
deis config:set ALLOWED_HOSTS=\* -a nucleus-prod

kubectl -n nucleus-prod apply -f ./k8s/nucleus-prod-nodeport.yaml

