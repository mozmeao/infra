#!/bin/bash

source ../bin/common.sh
check_meao_env

deis limits:set web=120M/300M -a careers-prod
deis limits:set web=250m/500m --cpu -a careers-prod
deis autoscale:set web --min=3 --max=5 --cpu-percent=80 -a careers-prod


