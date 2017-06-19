#!/bin/bash

source ../bin/common.sh
check_meao_env

deis apps:destroy -a basket-dev --confirm=basket-dev
deis apps:destroy -a basket-stage --confirm=basket-stage
deis apps:destroy -a basket-prod --confirm=basket-prod
