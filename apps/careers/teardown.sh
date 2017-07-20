#!/bin/bash

source ../bin/common.sh
check_meao_env

deis apps:destroy -a careers-prod  --confirm careers-prod

neres delete-monitor $(get_newrelic_monitor_id "Careers Tokyo")
neres delete-monitor $(get_newrelic_monitor_id "Careers Frankfurt")
