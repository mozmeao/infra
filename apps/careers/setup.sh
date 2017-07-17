#!/bin/bash -e

source ../bin/common.sh
check_meao_env

wget https://raw.githubusercontent.com/mozmar/lumbergh/master/Procfile

deis create careers-prod --no-remote
deis config:set ALLOWED_HOSTS=\* -a careers-prod
deis domains:add careers.mozilla.com -a careers-prod
kubectl -n careers-prod apply -f ./k8s/careers-prod-nodeport.yaml
deis pull mozorg/lumbergh:a66c97 -a careers-prod
