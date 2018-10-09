#!/bin/bash
if [ -z "$FLUENTD_SYSLOG_HOST" ]; then
    echo "Please set FLUENTD_SYSLOG_HOST"
    exit 1
fi

if [ -z "$FLUENTD_SYSLOG_PORT" ]; then
    echo "Please set FLUENTD_SYSLOG_PORT"
    exit 1
fi

export FLUENTD_CPU_LIMIT=100m
export FLUENTD_MEMORY_LIMIT=256Mi
export FLUENTD_IMAGE=quay.io/mozmar/fluentd:6aad24da11225a258bf010583c675bb7a8e8e7da

docker run -v $(pwd):/mozmeao \
    -e FLUENTD_SYSLOG_HOST="${FLUENTD_SYSLOG_HOST}" \
    -e FLUENTD_SYSLOG_PORT="${FLUENTD_SYSLOG_PORT}" \
    -e FLUENTD_CPU_LIMIT="${FLUENTD_CPU_LIMIT}" \
    -e FLUENTD_MEMORY_LIMIT="${FLUENTD_MEMORY_LIMIT}" \
    -e FLUENTD_IMAGE="${FLUENTD_IMAGE}" \
    -e FLUENTD_ON_MASTER="${FLUENTD_ON_MASTER:-true}" \
    -it python:2 bash -c "pip install j2; j2 /mozmeao/fluentd.yaml.j2 > /mozmeao/fluentd.yaml.out"
        