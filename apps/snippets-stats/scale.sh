#!/bin/bash

source ../bin/common.sh
check_meao_env

deis limits:set web=128M/300M -a snippets-stats
deis limits:set web=50m/100m --cpu -a snippets-stats
deis autoscale:set web --min=5 --max=10 --cpu-percent=80 -a snippets-stats
