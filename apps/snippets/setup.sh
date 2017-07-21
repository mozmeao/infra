#!/bin/bash -e

source ../bin/common.sh
check_meao_env
check_neres_env

setup_monitors() {
    create_monitor_if_missing \
        "Snippets Prod Tokyo" \
        "https://snippets-prod.tokyo.moz.works/4/Firefox/30.0/20140605174243/WINNT_x86-msvc/en-US/release/Windows_NT%206.1/default/default/" \
        "AWS_AP_NORTHEAST_1" \
        "var ABOUTHOME_SNIPPETS ="

    create_monitor_if_missing \
        "Snippets Prod Frankfurt" \
        "https://snippets-prod.frankfurt.moz.works/4/Firefox/30.0/20140605174243/WINNT_x86-msvc/en-US/release/Windows_NT%206.1/default/default/" \
        "AWS_EU_CENTRAL_1" \
        "var ABOUTHOME_SNIPPETS ="
}


wget https://raw.githubusercontent.com/mozmeao/snippets-service/master/Procfile
deis create snippets-prod --no-remote
deis perms:create jenkins -a snippets-prod

kubectl -n snippets-prod apply -f ./k8s/snippets-prod-nodeport.yaml

deis domains:add snippets.mozilla.com -a snippets-prod

deis config:set ALLOWED_HOSTS=snippets-prod.frankfurt,snippets-prod.moz.works,snippets.cdn.mozilla.net,snippets-prod-cdn.moz.works,snippets.mozilla.com -a snippets-prod

deis pull mozorg/snippets:06ce45 -a snippets-prod

setup_monitors
echo "See README.md for additional setup"

