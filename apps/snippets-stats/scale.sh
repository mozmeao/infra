#!/bin/bash

source ../bin/common.sh
check_meao_env

deis limits:set cmd=128M/300M -a snippets-stats
deis limits:set cmd=50m/100m --cpu -a snippets-stats
deis autoscale:set cmd --min=3 --max=10 --cpu-percent=80 -a snippets-stats
