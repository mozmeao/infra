
#!/bin/bash

source ../bin/common.sh
check_neres_env

neres add-monitor "MDN interactive-examples" \
    https://interactive-examples.mdn.moz.works \
    --location AWS_US_WEST_2 \
    --frequency 5 \
    --email "${NERES_EMAIL_1}" \
    --email "${NERES_EMAIL_2}"

