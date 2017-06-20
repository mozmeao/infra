#!/bin/bash

source ../bin/common.sh
#check_meao_env

check_neres_env

neres add-monitor "Viewsourceconf prod" \
    https://viewsourceconf.org \
    --location AWS_US_WEST_2 \
    --frequency 5 \
    --email "${NERES_EMAIL_1}" \
    --email "${NERES_EMAIL_2}"

