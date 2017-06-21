#!/bin/bash -e

source ../bin/common.sh
check_meao_env

wget https://raw.githubusercontent.com/mozilla/bedrock/master/Procfile

deis create bedrock-prod --no-remote
deis create bedrock-stage --no-remote
deis create bedrock-dev --no-remote

deis config:set ALLOWED_HOSTS=\* -a bedrock-prod
deis config:set ALLOWED_HOSTS=\* -a bedrock-stage
deis config:set ALLOWED_HOSTS=\* -a bedrock-dev

deis domains:add www.allizom.org -a bedrock-stage
deis config:set DEIS_DOMAIN=frankfurt.moz.works -a bedrock-stage

deis domains:add www.mozilla.org -a bedrock-prod
deis config:set DEIS_DOMAIN=frankfurt.moz.works -a bedrock-prod

kubectl -n bedrock-prod apply -f ./k8s/bedrock-prod-nodeport.yaml
kubectl -n bedrock-stage apply -f ./k8s/bedrock-stage-nodeport.yaml

deis pull mozorg/bedrock:latest -a bedrock-prod
deis pull mozorg/bedrock:latest -a bedrock-stage
deis pull mozorg/bedrock:latest -a bedrock-dev


