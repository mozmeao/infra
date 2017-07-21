#!/bin/bash

source ../bin/common.sh
check_meao_env

deis apps:destroy -a snippets-stats --confirm snippets-stats

neres delete-monitor $(get_newrelic_monitor_id "Snippets Stats Tokyo")
neres delete-monitor $(get_newrelic_monitor_id "Snippets Stats Frankfurt")

