#!/bin/bash

source ../bin/common.sh
check_meao_env
check_neres_env

deis apps:destroy -a snippets-prod  --confirm snippets-prod

neres delete-monitor $(get_newrelic_monitor_id "Snippets Prod Tokyo")
neres delete-monitor $(get_newrelic_monitor_id "Snippets Prod Frankfurt")


