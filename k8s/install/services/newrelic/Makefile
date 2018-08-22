export CLUSTER_NAME ?= k8s

render-cfg: check-env
	@echo "Rendering newrelic-daemonset.yaml"
	cat newrelic-daemonset.yaml.tmpl | envsubst > newrelic-daemonset.yaml

check-env:
ifndef CLUSTER_NAME
	$(error CLUSTER_NAME is undefined)
endif

.PHONY: render-cfg
