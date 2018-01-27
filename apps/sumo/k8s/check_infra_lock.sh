#!/bin/bash
if [ -z ${CHANGE_SUMO_INFRA+x} ]
then
    echo "CHANGE_SUMO_INFRA is not set. Set it to any value to allow infra changes."
    exit 1
fi