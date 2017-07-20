#!/bin/bash -e

source ../bin/common.sh
check_meao_env
check_neres_env

setup_monitors() {
    create_monitor_if_missing \
        "Careers Tokyo" \
        "https://careers-prod.tokyo.moz.works" \
        "AWS_AP_NORTHEAST_1"

    create_monitor_if_missing \
        "Careers Frankfurt" \
        "https://careers-prod.frankfurt.moz.works" \
        "AWS_EU_CENTRAL_1"
}

wget https://raw.githubusercontent.com/mozmar/lumbergh/master/Procfile

deis create careers-prod --no-remote
deis perms:create jenkins -a careers-prod

deis config:set ALLOWED_HOSTS=\* -a careers-prod
deis domains:add careers.mozilla.com -a careers-prod
kubectl -n careers-prod apply -f ./k8s/careers-prod-nodeport.yaml
deis pull mozorg/lumbergh:a66c97 -a careers-prod
