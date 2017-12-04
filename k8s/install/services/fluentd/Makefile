export FLUENTD_CPU_LIMIT ?= 100m
export FLUENTD_MEMORY_LIMIT ?= 256Mi
export RENDER_POD_CMD ?= j2 fluentd.yaml.j2 | kubectl apply -f -
export FLUENTD_IMAGE ?= quay.io/mozmar/fluentd:6aad24da11225a258bf010583c675bb7a8e8e7da

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

