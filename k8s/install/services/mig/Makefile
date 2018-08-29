export MIG_IMAGE ?= quay.io/mozmar/mig:8a3f0aaa97dccc808919f7cc561927571980893b
export MQUSER ?= agent-engeng

render-agent-cfg: check-env
	@echo "Rendering mig-agent config"
	cat mig-agent.cfg.tmpl | envsubst > mig-agent.cfg

check-env:
ifndef MQPASSWORD
	$(error MQPASSWORD is undefined)
endif

.PHONY: render-agent-cfg

