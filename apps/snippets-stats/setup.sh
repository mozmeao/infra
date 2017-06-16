#!/bin/bash -e

source ../bin/common.sh
check_meao_env

deis create snippets-stats-prod --no-remote
deis config:set ALLOWED_HOSTS=\* -a snippets-stats-prod
kubectl -n snippets-stats-prod apply -f ./snippets-stats-prod-nodeport.yaml
deis pull mozmeao/snippets-stats:37727e -a snippets-stats-prod
