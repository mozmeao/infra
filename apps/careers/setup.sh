#!/bin/bash -e

source ../bin/common.sh
check_meao_env

deis create careers-prod --no-remote
deis pull mozorg/lumbergh:2b7d32 -a careers-prod
deis config:set ALLOWED_HOSTS=\* -a careers-prod
kubectl -n careers-prod apply -f ./k8s/careers-prod-nodeport.yaml
#
