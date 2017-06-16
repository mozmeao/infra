#!/bin/bash -e

if [ -z "$DEIS_PROFILE" ]; then
    echo "Please set DEIS_PROFILE"
    exit 1
fi


if [ -z "$KUBECONFIG" ]; then
    echo "Please set KUBECONFIG"
    exit 1
fi


wget https://raw.githubusercontent.com/mozilla/bedrock/master/Procfile

deis create bedrock-prod --no-remote
deis create bedrock-stage --no-remote
deis create bedrock-dev --no-remote

deis config:set ALLOWED_HOSTS=\* -a bedrock-prod
deis config:set ALLOWED_HOSTS=\* -a bedrock-stage
deis config:set ALLOWED_HOSTS=\* -a bedrock-dev

kubectl -n bedrock-prod apply -f ./k8s/bedrock-prod-nodeport.yaml
kubectl -n bedrock-stage apply -f ./k8s/bedrock-stage-nodeport.yaml

deis pull mozorg/bedrock:latest -a bedrock-prod
deis pull mozorg/bedrock:latest -a bedrock-stage
deis pull mozorg/bedrock:latest -a bedrock-dev


