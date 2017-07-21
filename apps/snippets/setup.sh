#!/bin/bash -e

source ../bin/common.sh
check_meao_env

wget https://raw.githubusercontent.com/mozmeao/snippets-service/master/Procfile
deis create snippets-prod --no-remote
deis perms:create jenkins -a snippets-prod

kubectl -n snippets-prod apply -f ./k8s/snippets-prod-nodeport.yaml

deis domains:add snippets.mozilla.com -a snippets-prod

deis config:set ALLOWED_HOSTS=snippets-prod.frankfurt,snippets-prod.moz.works,snippets.cdn.mozilla.net,snippets-prod-cdn.moz.works,snippets.mozilla.com -a snippets-prod

deis pull mozorg/snippets:06ce45 -a snippets-prod


echo "See README.md for additional setup"

