#!/bin/bash

source ../bin/common.sh
check_meao_env

deis apps:destroy -a careers-prod  --confirm careers-prod
