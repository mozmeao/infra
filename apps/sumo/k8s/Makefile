# Define defaults for environment variables that personalize the commands.
export TARGET_ENVIRONMENT ?= dev
export K8S_NAMESPACE ?= SUMO-${TARGET_ENVIRONMENT}
export AWS_RESOURCE_STACK=SUMO-${TARGET_ENVIRONMENT}
export AWS_REGION ?= us-west-2
export SUMO_SECRETS_NAME ?= sumo-secrets-${TARGET_ENVIRONMENT}
export SUMO_IMAGE ?= mozmar/sumo-dev
export SUMO_IMAGE_TAG ?= latest
export SUMO_IMAGE_PULL_POLICY ?= IfNotPresent
export SUMO_APP_NAME ?= sumo-${TARGET_ENVIRONMENT}
export SUMO_WEB_DEPLOYMENT_NAME ?= sumo-${TARGET_ENVIRONMENT}-web
export SUMO_NODEPORT_NAME ?= sumo-nodeport

## Readiness Probes
export READINESS_FAILURE_THRESHOLD ?= 1
export READINESS_INITIAL_DELAY_SECONDS ?= 5
export READINESS_PERIOD_SECONDS ?= 5
export READINESS_SUCCESS_THRESHOLD ?= 1
export READINESS_TCP_SOCKET_PORT ?= 8000
export READINESS_TIMEOUT_SECONDS ?= 5

default:
	@echo "Please choose a target!"

check-service-env:
	./check_infra_lock.sh

## Deployments
k8s-web: 
	j2 sumo-web.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-web:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${SUMO_WEB_DEPLOYMENT_NAME}

## Services
k8s-nodeport: check-service-env
	j2 sumo-nodeport.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-nodeport:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found service ${SUMO_NODEPORT_NAME}

## Rollout/Rollback

k8s-sumo-rollout-status:
	kubectl -n ${K8S_NAMESPACE} rollout status deploy ${SUMO_WEB_DEPLOYMENT_NAME}

k8s-sumo-rollback:
	kubectl -n ${K8S_NAMESPACE} rollout undo deploy ${SUMO_WEB_DEPLOYMENT_NAME}

# These tasks don't have file targets
.PHONY: k8s-web k8s-delete-web k8s-nodeport k8s-delete-nodeport