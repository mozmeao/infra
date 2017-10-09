#!/bin/bash

source ../bin/common.sh
check_meao_env

deis scale web=3 -a snippets-admin
deis scale clock=1 -a snippets-admin
