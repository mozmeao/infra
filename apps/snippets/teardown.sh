#!/bin/bash

source ../bin/common.sh
check_meao_env

deis apps:destroy -a snippets-prod  --confirm snippets-prod
