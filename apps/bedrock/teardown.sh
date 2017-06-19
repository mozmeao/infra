#!/bin/bash

source ../bin/common.sh
check_meao_env

deis apps:destroy -a bedrock-prod  --confirm bedrock-prod
deis apps:destroy -a bedrock-stage --confirm bedrock-stage
deis apps:destroy -a bedrock-dev   --confirm bedrock-dev
