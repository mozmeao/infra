#!/bin/bash -e

source ../bin/common.sh
check_meao_env
check_neres_env

setup_monitors() {
    create_monitor_if_missing \
        "Snippets Stats Tokyo" \
        "https://snippets-stats.tokyo.moz.works" \
        "AWS_AP_NORTHEAST_1"

    create_monitor_if_missing \
        "Snippets Stats Frankfurt" \
        "https://snippets-stats.frankfurt.moz.works" \
        "AWS_EU_CENTRAL_1"
}

deis create snippets-stats --no-remote
deis perms:create jenkins -a snippets-stats
deis domains:add snippets-stats.moz.works -a snippets-stats

deis config:set ALLOWED_HOSTS=\* -a snippets-stats
kubectl -n snippets-stats apply -f ./k8s/snippets-stats-nodeport.yaml
deis pull mozmeao/snippets-stats:37727e -a snippets-stats

setup_monitors

echo "See README.md for additional setup"
