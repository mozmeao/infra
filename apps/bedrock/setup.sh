#!/bin/bash -e

if [ -z "$DEIS_PROFILE" ]; then
    echo "Please set DEIS_PROFILE"
    exit 1
fi


if [ -z "$KUBECONFIG" ]; then
    echo "Please set KUBECONFIG"
    exit 1
fi

#deis create bedrock-prod --no-remote
#deis create bedrock-stage --no-remote
#deis create bedrock-dev --no-remote

#deis pull mozorg/bedrock:latest -a bedrock-prod
#deis pull mozorg/bedrock:latest -a bedrock-stage
#deis pull mozorg/bedrock:latest -a bedrock-dev

#deis limits:set web=300M/600M -a bedrock-prod
#deis limits:set web=250m/1000m --cpu -a bedrock-prod
#deis autoscale:set web --min=5 --max=20 --cpu-percent=80 -a bedrock-prod
#
#deis limits:set web=300M/600M -a bedrock-stage
#deis limits:set web=250m/1000m --cpu -a bedrock-stage
#deis autoscale:set web --min=5 --max=20 --cpu-percent=80 -a bedrock-stage
#
#deis limits:set web=120M/300M -a bedrock-dev
#deis limits:set web=250m/500m --cpu  -a bedrock-dev
#deis autoscale:set web --min=3 --max=5 --cpu-percent=80 -a bedrock-dev
#
#deis config:set ALLOWED_HOSTS=\* -a bedrock-prod
#deis config:set ALLOWED_HOSTS=\* -a bedrock-stage
#deis config:set ALLOWED_HOSTS=\* -a bedrock-dev

kubectl -n bedrock-prod apply -f ./k8s/bedrock-prod-nodeport.yaml
kubectl -n bedrock-stage apply -f ./k8s/bedrock-stage-nodeport.yaml

