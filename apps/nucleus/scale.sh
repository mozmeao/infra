#!/bin/bash

source ../bin/common.sh
check_meao_env

deis limits:set web=150M/300M -a nucleus-prod
deis limits:set web=100m/250m --cpu -a nucleus-prod
deis autoscale:set cmd --min=3 --max=5 --cpu-percent=80 -a nucleus-prod
