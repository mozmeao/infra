#!/bin/bash

source ../bin/common.sh
check_meao_env

deis scale cmd=1 -a datadog-cloudflare-sync
