#!/bin/bash

source ../bin/common.sh
check_meao_env

deis limits:set web=300M/600M -a bedrock-prod
deis limits:set web=250m/1000m --cpu -a bedrock-prod
deis limits:set clock=300M/600M -a bedrock-prod
deis limits:set clock=250m/1000m --cpu -a bedrock-prod
deis autoscale:set web --min=5 --max=20 --cpu-percent=80 -a bedrock-prod
#deis autoscale:set clock --min=1 --max=1--cpu-percent=80 -a bedrock-prod


deis limits:set web=300M/600M -a bedrock-stage
deis limits:set web=250m/1000m --cpu -a bedrock-stage
deis limits:set clock=300M/600M -a bedrock-stage
deis limits:set clock=250m/1000m --cpu -a bedrock-stage
deis autoscale:set web --min=5 --max=20 --cpu-percent=80 -a bedrock-stage
#deis autoscale:set clock --min=1 --max=1 --cpu-percent=80 -a bedrock-stage

deis limits:set web=120M/300M -a bedrock-dev
deis limits:set web=250m/500m --cpu  -a bedrock-dev
deis limits:set clock=120M/300M -a bedrock-dev
deis limits:set clock=250m/500m --cpu  -a bedrock-dev
deis autoscale:set web --min=1 --max=3 --cpu-percent=80 -a bedrock-dev
#deis autoscale:set clock --min=1 --max=1 --cpu-percent=80 -a bedrock-dev

# scale the clock process
# this will run DB migrations on it's first run
deis scale clock=1 -a bedrock-prod
deis scale clock=1 -a bedrock-stage
deis scale clock=1 -a bedrock-dev
