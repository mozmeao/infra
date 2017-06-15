#!/bin/bash -e

if [ -z "$DEIS_PROFILE" ]; then
    echo "Please set DEIS_PROFILE"
    exit 1
fi


if [ -z "$KUBECONFIG" ]; then
    echo "Please set KUBECONFIG"
    exit 1
fi

deis create basket-prod --no-remote
deis create basket-stage --no-remote
deis create basket-dev --no-remote

deis pull mozmeao/basket:4094a3dcf780a1996b5b404487288643d3bacc46 -a basket-prod
deis pull mozmeao/basket:4094a3dcf780a1996b5b404487288643d3bacc46 -a basket-stage
deis pull mozmeao/basket:4094a3dcf780a1996b5b404487288643d3bacc46 -a basket-dev

deis config:set ALLOWED_HOSTS=\* -a basket-prod
deis config:set ALLOWED_HOSTS=\* -a basket-stage
deis config:set ALLOWED_HOSTS=\* -a basket-dev

kubectl -n basket-prod apply -f ./k8s/basket-prod-nodeport.yaml
kubectl -n basket-stage apply -f ./k8s/basket-stage-nodeport.yaml

