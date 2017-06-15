#!/bin/bash

deis limits:set web=150M/300M -a nucleus-dev
deis limits:set web=100m/250m --cpu -a nucleus-dev
deis autoscale:set web --min=3 --max=5 --cpu-percent=80 -a nucleus-dev

deis limits:set web=150M/300M -a nucleus-prod
deis limits:set web=100m/250m --cpu -a nucleus-prod
deis autoscale:set cmd --min=3 --max=5 --cpu-percent=80 -a nucleus-prod
