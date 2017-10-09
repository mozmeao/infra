#!/bin/bash

source ../bin/common.sh
check_meao_env

deis limits:set web=300M/600M -a snippets-prod
deis limits:set web=250m/1000m --cpu -a snippets-prod
deis autoscale:set web --min=10 --max=30 --cpu-percent=80 -a snippets-prod
