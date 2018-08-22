export AUTOSCALER_CPU_LIMIT ?= 100m
export AUTOSCALER_MEMORY_LIMIT ?= 300Mi
export AWS_REGION ?= us-west-2
export RENDER_POD_CMD ?= j2 autoscaler.yaml.j2 | kubectl apply -f -
export AUTOSCALER_IMAGE ?= k8s.gcr.io/cluster-autoscaler:v1.3.0

install-autoscaler: check-env
	${RENDER_POD_CMD}

# Note that ifndef and endif are not indented to process env vars
# before the rest of the script
check-env:
ifndef MAX_NODES
	$(error MAX_NODES is not defined)
endif

.PHONY: check-env

