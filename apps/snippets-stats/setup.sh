#!/bin/bash -e

source ../bin/common.sh
check_meao_env

#deis create snippets-stats --no-remote
#deis config:set ALLOWED_HOSTS=\* -a snippets-stats
kubectl -n snippets-stats apply -f ./k8s/snippets-stats-nodeport.yaml
deis pull mozmeao/snippets-stats:37727e -a snippets-stats
