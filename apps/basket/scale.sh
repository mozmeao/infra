#!/bin/bash

source ../bin/common.sh
check_meao_env

deis limits:set web=150M/300M -a basket-dev
deis limits:set web=100m/200m --cpu -a basket-dev
deis autoscale:set web --min=1 --max=3 --cpu-percent=80 -a basket-dev

deis limits:set web=300M/600M -a basket-stage
deis limits:set web=250m/1000m --cpu -a basket-stage
deis autoscale:set web --min=3 --max=3 --cpu-percent=80 -a basket-stage

deis limits:set web=300M/600M -a basket-prod
deis limits:set web=250m/1000m --cpu -a basket-prod
deis autoscale:set web --min=5 --max=20 --cpu-percent=80 -a basket-prod
