
export FLUENTD_CPU_LIMIT ?= 100m
export FLUENTD_MEMORY_LIMIT ?= 768Mi
#export FLUENTD_SYSLOG_HOST ?= null
#export FLUENTD_SYSLOG_PORT ?= null
export RENDER_POD_CMD ?= j2 fluentd.yaml.j2 | kubectl create -f -

check-env:
	ifndef FLUENTD_SYSLOG_HOST
	    $(error FLUENTD_SYSLOG_HOST is undefined)
	endif
	ifndef FLUENTD_SYSLOG_PORT
	    $(error FLUENTD_SYSLOG_PORT is undefined)
	endif

install-fluentd:
	${RENDER_POD_CMD}

