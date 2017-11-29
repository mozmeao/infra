export FLUENTD_CPU_LIMIT ?= 100m
export FLUENTD_MEMORY_LIMIT ?= 768Mi
export RENDER_POD_CMD ?= j2 fluentd.yaml.j2 | kubectl create -f -
export FLUENTD_IMAGE ?= quay.io/mozmar/fluentd:60835bc5d814d1901207d375c5ad9c9b0a1b66a3

install-fluentd: check-env
	${RENDER_POD_CMD}

# Note that ifndef and endif are not indented to process env vars
# before the rest of the script
check-env:
ifndef FLUENTD_SYSLOG_HOST
	$(error FLUENTD_SYSLOG_HOST is undefined)
endif
ifndef FLUENTD_SYSLOG_PORT
	$(error FLUENTD_SYSLOG_PORT is undefined)
endif

.PHONY: check-env

