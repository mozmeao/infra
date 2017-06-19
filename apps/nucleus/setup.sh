#!/bin/bash -e

source ../bin/common.sh
check_meao_env

deis create nucleus-prod --no-remote
deis config:unset SECURE_SSL_REDIRECT -a nucleus-prod | true
deis config:set SSL_DISABLE=True -a nucleus-prod
deis config:set ALLOWED_HOSTS=\* -a nucleus-prod
kubectl -n nucleus-prod apply -f ./k8s/nucleus-prod-nodeport.yaml

deis pull quay.io/mozmar/nucleus:3a4dbfe489cc1674742068b38735551711d013e5 -a nucleus-prod
