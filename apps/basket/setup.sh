#!/bin/bash -e

if [ -z "$DEIS_PROFILE" ]; then
    echo "Please set DEIS_PROFILE"
    exit 1
fi


if [ -z "$KUBECONFIG" ]; then
    echo "Please set KUBECONFIG"
    exit 1
fi

#deis create basket-prod --no-remote
#deis create basket-stage --no-remote
#deis create basket-dev --no-remote

#deis pull mozmeao/basket:4094a3dcf780a1996b5b404487288643d3bacc46 -a basket-prod
#deis pull mozmeao/basket:4094a3dcf780a1996b5b404487288643d3bacc46 -a basket-stage
#deis pull mozmeao/basket:4094a3dcf780a1996b5b404487288643d3bacc46 -a basket-dev

deis limits:set web=150M/300M -a basket-dev
deis limits:set web=100m/200m --cpu -a basket-dev
deis autoscale:set web --min=1 --max=3 --cpu-percent=80 -a basket-dev

deis limits:set web=300M/600M -a basket-stage
deis limits:set web=250m/1000m --cpu -a basket-stage
deis autoscale:set web --min=3 --max=3 --cpu-percent=80 -a basket-stage

deis limits:set web=300M/600M -a basket-prod
deis limits:set web=250m/1000m --cpu -a basket-prod
deis autoscale:set web --min=5 --max=20 --cpu-percent=80 -a basket-prod

deis config:set ALLOWED_HOSTS=\* -a basket-prod
deis config:set ALLOWED_HOSTS=\* -a basket-stage
deis config:set ALLOWED_HOSTS=\* -a basket-dev

kubectl -n basket-prod apply -f ./k8s/basket-prod-nodeport.yaml
kubectl -n basket-stage apply -f ./k8s/basket-stage-nodeport.yaml

