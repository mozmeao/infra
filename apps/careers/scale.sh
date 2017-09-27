#!/bin/bash

source ../bin/common.sh
check_meao_env

deis limits:set web=128M/150M -a careers-prod
deis limits:set web=100m/200m --cpu -a careers-prod
deis autoscale:set web --min=2 --max=5 --cpu-percent=80 -a careers-prod
