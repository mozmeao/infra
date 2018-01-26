# Define defaults for environment variables that personalize the commands.
export TARGET_ENVIRONMENT ?= dev
export K8S_NAMESPACE ?= SUMO-${TARGET_ENVIRONMENT}
export AWS_RESOURCE_STACK=SUMO-${TARGET_ENVIRONMENT}
export AWS_REGION ?= us-west-2
export SUMO_SECRETS_NAME ?= sumo-secrets-${TARGET_ENVIRONMENT}
export SUMO_IMAGE ?= mozmar/sumo-dev:v38
export SUMO_IMAGE_PULL_POLICY ?= IfNotPresent
export SUMO_APP_NAME ?= sumo-${TARGET_ENVIRONMENT}
export SUMO_WEB_DEPLOYMENT_NAME ?= sumo-${TARGET_ENVIRONMENT}-web

## Readiness Probes
export READINESS_FAILURE_THRESHOLD ?= 1
export READINESS_INITIAL_DELAY_SECONDS ?= 5
export READINESS_PERIOD_SECONDS ?= 5
export READINESS_SUCCESS_THRESHOLD ?= 1
export READINESS_TCP_SOCKET_PORT ?= 8000
export READINESS_TIMEOUT_SECONDS ?= 5

		
k8s-web: 
	j2 sumo-web.yaml.j2 #| kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-web:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${SUMO_WEB_DEPLOYMENT_NAME}