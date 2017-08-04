# Define defaults for environment variables that personalize the commands.
export TARGET_ENVIRONMENT ?= dev
export K8S_NAMESPACE ?= mdn-${TARGET_ENVIRONMENT}
export AWS_RESOURCE_STACK=MDN-${TARGET_ENVIRONMENT}
export AWS_REGION ?= us-west-2

# Note PVs are available within ALL namespaces, so delimit them with
# the name of the target environment.
export SHARED_PV_NAME ?= mdn-shared-${TARGET_ENVIRONMENT}
export SHARED_PV_SIZE ?= 1000Gi
export SHARED_PV_RECLAIM_POLICY ?= Retain
export SHARED_PV_MOUNT_PATH ?= /
export SHARED_PV_ARN ?= fs-e89b4341.efs.us-west-2.amazonaws.com
export SHARED_PV_STORAGE_CLASS_NAME ?= efs

export SHARED_PVC_NAME ?= mdn-shared
export SHARED_PVC_SIZE ?= 40Gi

export MYSQL_NAME ?= mysql
export MYSQL_SERVICE_TYPE ?= ClusterIP
export MYSQL_SERVICE_PORT ?= 3306
export MYSQL_SERVICE_TARGET_PORT ?= mysql
export MYSQL_SERVICE_PROTOCOL ?= TCP
export MYSQL_IMAGE ?= quay.io/mozmar/mdn-mysql
export MYSQL_IMAGE_TAG ?= latest
export MYSQL_IMAGE_PULL_POLICY ?= IfNotPresent
MYSQL_STORAGE_SIZE_IN_GB ?= 40
export MYSQL_STORAGE_NAME ?= ${MYSQL_NAME}-${TARGET_ENVIRONMENT}
export MYSQL_STORAGE_SIZE ?= ${MYSQL_STORAGE_SIZE_IN_GB}Gi
export MYSQL_STORAGE_RECLAIM_POLICY ?= Retain
export MYSQL_STORAGE_EBS_ARN ?= vol-0306362068285e689
export MYSQL_STORAGE_EBS_TYPE ?= gp2
export MYSQL_STORAGE_EBS_AZ ?= us-west-2a
export MYSQL_USER ?= kuma
export MYSQL_PASSWORD ?= kuma
export MYSQL_ROOT_PASSWORD ?= kuma
export MYSQL_DATABASE ?= developer_mozilla_org

export WEB_SERVICE_NAME ?= web
export WEB_SERVICE_TYPE ?= LoadBalancer
export WEB_SERVICE_PORT ?= 80
export WEB_SERVICE_TARGET_PORT ?= 8000
export WEB_SERVICE_PROTOCOL ?= TCP

export API_SERVICE_NAME ?= api
export API_SERVICE_TYPE ?= ClusterIP
export API_SERVICE_PORT ?= 80
export API_SERVICE_TARGET_PORT ?= 8000
export API_SERVICE_PROTOCOL ?= TCP

export KUMASCRIPT_SERVICE_NAME ?= kumascript
export KUMASCRIPT_SERVICE_TYPE ?= ClusterIP
export KUMASCRIPT_SERVICE_PORT ?= 9080
export KUMASCRIPT_SERVICE_TARGET_PORT ?= 9080
export KUMASCRIPT_SERVICE_PROTOCOL ?= TCP

export MEMCACHED_URL ?= mdn-memcached-dev.9zzabg.cfg.usw2.cache.amazonaws.com:11121
export ELASTICSEARCH_URL ?= elasticsearch:9200

export WEB_NAME ?= web
export WEB_REPLICAS ?= 1
export WEB_GUNICORN_WORKERS ?= 4
export WEB_GUNICORN_TIMEOUT ?= 120
export WEB_CPU_LIMIT ?= 2
export WEB_CPU_REQUEST ?= 100m
export WEB_MEMORY_LIMIT ?= 4Gi
export WEB_MEMORY_REQUEST ?= 256Mi

export API_NAME ?= api
export API_REPLICAS ?= 1
export API_GUNICORN_WORKERS ?= 4
export API_GUNICORN_TIMEOUT ?= 120
export API_CPU_LIMIT ?= 2
export API_CPU_REQUEST ?= 100m
export API_MEMORY_LIMIT ?= 4Gi
export API_MEMORY_REQUEST ?= 256Mi

export CELERY_WORKERS_NAME ?= celery-worker
export CELERY_WORKERS_REPLICAS ?= 1
export CELERY_WORKERS_CPU_LIMIT ?= 2
export CELERY_WORKERS_CPU_REQUEST ?= 100m
export CELERY_WORKERS_MEMORY_LIMIT ?= 4Gi
export CELERY_WORKERS_MEMORY_REQUEST ?= 256Mi
export CELERY_WORKERS_CONCURRENCY ?= 4
export CELERY_WORKERS_QUEUES ?= mdn_purgeable,mdn_search,mdn_emails,mdn_wiki,celery

export CELERY_BEAT_NAME ?= celery-beat
export CELERY_BEAT_REPLICAS ?= 1
export CELERY_BEAT_CPU_LIMIT ?= 2
export CELERY_BEAT_CPU_REQUEST ?= 100m
export CELERY_BEAT_MEMORY_LIMIT ?= 4Gi
export CELERY_BEAT_MEMORY_REQUEST ?= 256Mi

export CELERY_CAM_NAME ?= celery-cam
export CELERY_CAM_REPLICAS ?= 1
export CELERY_CAM_CPU_LIMIT ?= 2
export CELERY_CAM_CPU_REQUEST ?= 100m
export CELERY_CAM_MEMORY_LIMIT ?= 4Gi
export CELERY_CAM_MEMORY_REQUEST ?= 256Mi

export KUMASCRIPT_NAME ?= kumascript
export KUMASCRIPT_REPLICAS ?= 1
export KUMASCRIPT_CONTAINER_PORT ?= ${KUMASCRIPT_SERVICE_TARGET_PORT}
export KUMASCRIPT_IMAGE ?= quay.io/mozmar/kumascript
export KUMASCRIPT_IMAGE_TAG ?= latest
export KUMASCRIPT_IMAGE_PULL_POLICY ?= IfNotPresent
export KUMASCRIPT_CPU_LIMIT ?= 2
export KUMASCRIPT_CPU_REQUEST ?= 100m
export KUMASCRIPT_MEMORY_LIMIT ?= 4Gi
export KUMASCRIPT_MEMORY_REQUEST ?= 256Mi
export KUMASCRIPT_DOCUMENT_URL_TEMPLATE ?= http://${API_NAME}/en-US/docs/{path}?raw=1
export KUMASCRIPT_MEMCHACHED_URL ?= ${MEMCACHED_URL}

export KUMA_IMAGE ?= quay.io/mozmar/kuma
export KUMA_IMAGE_TAG ?= 2fcf608
export KUMA_IMAGE_PULL_POLICY ?= IfNotPresent
# "KUMA_MOUNT_PATH" sets the mount path for the claim of the shared volume.
export KUMA_MOUNT_PATH ?= /www
export KUMA_DEBUG ?= False
export KUMA_DEBUG_TOOLBAR ?= False
export KUMA_PROTOCOL ?= "https://"
ifeq (${TARGET_ENVIRONMENT},dev)
export KUMA_DOMAIN=$(shell kubectl get --ignore-not-found -n ${K8S_NAMESPACE} svc ${WEB_SERVICE_NAME} -o jsonpath={.status.loadBalancer.ingress[0].hostname})
else
export KUMA_DOMAIN ?= developer.mozilla.org
endif
export KUMA_ACCOUNT_DEFAULT_HTTP_PROTOCOL ?= "https"
export KUMA_ALLOWED_HOSTS ?= *
export KUMA_SESSION_COOKIE_SECURE ?= True
export KUMA_WEB_CONCURRENCY ?= 4
export KUMA_MAINTENANCE_MODE ?= False
export KUMA_CSRF_COOKIE_SECURE ?= True
export KUMA_CELERY_BROKER_URL ?= redis://mdn-redis-dev.9zzabg.ng.0001.usw2.cache.amazonaws.com:6379/0

# Define derived variables here. These are always set, even if defined externally.
export KUMA_SITE_URL="${KUMA_PROTOCOL}${KUMA_DOMAIN}"
export KUMA_URL_TEMPLATE_FOR_KUMASCRIPT=http://${KUMASCRIPT_SERVICE_NAME}:${KUMASCRIPT_SERVICE_PORT}/docs/{path}

# MDN backup tool
export BACKUP_SERVICE_NAME ?= mdn-backup-${TARGET_ENVIRONMENT}
export BACKUP_SECRETS_NAME ?= mdn-backup-secrets
export BACKUP_BUCKET ?= s3://mdn-shared-backup
# TODO: every minute for development only!
export BACKUP_SERVICE_SCHEDULE ?= "*/1 * * * *"
# https://kubernetes.io/docs/concepts/configuration/secret/
# the values below are NOT real access/secret keys
export BACKUP_ACCESS_KEY ?= foo
export BACKUP_SECRET_KEY ?= bar
export BACKUP_ACCESS_KEY_BASE64 ?= $(shell echo -n "${BACKUP_ACCESS_KEY}" | base64)
export BACKUP_SECRET_KEY_BASE64 ?= $(shell echo -n "${BACKUP_SECRET_KEY}" | base64)


aws-create-mysql-vol:
	aws ec2 create-volume \
		--region ${AWS_REGION} \
	    --size ${MYSQL_STORAGE_SIZE_IN_GB} \
	    --volume-type ${MYSQL_STORAGE_EBS_TYPE} \
		--availability-zone ${MYSQL_STORAGE_EBS_AZ} \
		--tag-specifications 'ResourceType=volume,Tags=[{Key=name,Value=mdn-mysql},{Key=purpose,Value=${TARGET_ENVIRONMENT}},{Key=created-by,Value=${USER}},{Key=Stack,Value=${AWS_RESOURCE_STACK}}]'

aws-describe-mysql-vols:
	aws ec2 describe-volumes \
		--region ${AWS_REGION} \
	    --filters Name=tag:name,Values="mdn-mysql"

k8s-services: k8s-ns k8s-shared-storage k8s-mysql-storage k8s-mysql-svc \
			  k8s-web-svc k8s-api-svc k8s-kumascript-svc k8s-secrets

k8s-delete-services: k8s-delete-ns k8s-delete-shared-storage \
					 k8s-delete-mysql-storage k8s-delete-mysql-svc \
					 k8s-delete-web-svc k8s-delete-api-svc \
					 k8s-delete-kumascript-svc k8s-delete-backup-secrets

k8s-ns:
	kubectl create ns ${K8S_NAMESPACE} | true

k8s-delete-ns:
	kubectl delete --ignore-not-found ns ${K8S_NAMESPACE}

k8s-pv-shared:
	j2 shared.pv.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-pv-shared:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pv ${SHARED_PV_NAME}

k8s-pvc-shared:
	j2 shared.pvc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-pvc-shared:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pvc ${SHARED_PVC_NAME}

k8s-shared-storage: k8s-pv-shared k8s-pvc-shared

k8s-delete-shared-storage: k8s-delete-pvc-shared k8s-delete-pv-shared

k8s-mysql-storage:
	j2 mysql.pv.pvc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-mysql-storage:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pv ${MYSQL_STORAGE_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pvc ${MYSQL_STORAGE_NAME}

k8s-web-svc:
	env SERVICE_NAME=${WEB_SERVICE_NAME} \
		SERVICE_TYPE=${WEB_SERVICE_TYPE} \
		SERVICE_PORT=${WEB_SERVICE_PORT} \
		SERVICE_TARGET_PORT=${WEB_SERVICE_TARGET_PORT} \
		SERVICE_PROTOCOL=${WEB_SERVICE_PROTOCOL} \
		j2 svc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-web-svc:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found \
		svc ${WEB_SERVICE_NAME}

k8s-api-svc:
	env SERVICE_NAME=${API_SERVICE_NAME} \
		SERVICE_TYPE=${API_SERVICE_TYPE} \
		SERVICE_PORT=${API_SERVICE_PORT} \
		SERVICE_TARGET_PORT=${API_SERVICE_TARGET_PORT} \
		SERVICE_PROTOCOL=${API_SERVICE_PROTOCOL} \
		j2 svc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-api-svc:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found \
		svc ${API_SERVICE_NAME}

k8s-kumascript-svc:
	env SERVICE_NAME=${KUMASCRIPT_SERVICE_NAME} \
		SERVICE_TYPE=${KUMASCRIPT_SERVICE_TYPE} \
		SERVICE_PORT=${KUMASCRIPT_SERVICE_PORT} \
		SERVICE_TARGET_PORT=${KUMASCRIPT_SERVICE_TARGET_PORT} \
		SERVICE_PROTOCOL=${KUMASCRIPT_SERVICE_PROTOCOL} \
		j2 svc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-kumascript-svc:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found \
		svc ${KUMASCRIPT_SERVICE_NAME}

k8s-mysql-svc:
	env SERVICE_NAME=${MYSQL_NAME} \
		SERVICE_TYPE=${MYSQL_SERVICE_TYPE} \
		SERVICE_PORT=${MYSQL_SERVICE_PORT} \
		SERVICE_TARGET_PORT=${MYSQL_SERVICE_TARGET_PORT} \
		SERVICE_PROTOCOL=${MYSQL_SERVICE_PROTOCOL} \
		j2 svc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-mysql-svc:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found svc ${MYSQL_NAME}

k8s-secrets: k8s-backup-secrets
k8s-delete-secrets: k8s-delete-backup-secrets

k8s-backup-secrets:
	j2 mdn-backup-secrets.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-backup-secrets:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found secret ${BACKUP_SECRETS_NAME}


################
# TODO
k8s-backup-cron:
	j2 mdn-backup-cron.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -
	#j2 mdn-backup-cron.yaml.j2 
################


k8s-deployments: k8s-mysql k8s-web k8s-api k8s-kumascript k8s-celery

k8s-delete-deployments: k8s-delete-mysql k8s-delete-web k8s-delete-api \
						k8s-delete-kumascript k8s-delete-celery

k8s-mysql:
	j2 mysql.deploy.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-mysql:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${MYSQL_NAME}

k8s-web:
	env KUMA_NAME=${WEB_NAME} \
		KUMA_REPLICAS=${WEB_REPLICAS} \
		KUMA_CONTAINER_PORT=${WEB_SERVICE_TARGET_PORT} \
		KUMA_GUNICORN_WORKERS=${WEB_GUNICORN_WORKERS} \
		KUMA_GUNICORN_TIMEOUT=${WEB_GUNICORN_TIMEOUT} \
		KUMA_CPU_LIMIT=${WEB_CPU_LIMIT} \
		KUMA_MEMORY_LIMIT=${WEB_MEMORY_LIMIT} \
		KUMA_CPU_REQUEST=${WEB_CPU_REQUEST} \
		KUMA_MEMORY_REQUEST=${WEB_MEMORY_REQUEST} \
		j2 kuma.deploy.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-web:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${WEB_NAME}

k8s-api:
	env KUMA_NAME=${API_NAME} \
		KUMA_REPLICAS=${API_REPLICAS} \
		KUMA_CONTAINER_PORT=${API_SERVICE_TARGET_PORT} \
		KUMA_GUNICORN_WORKERS=${API_GUNICORN_WORKERS} \
		KUMA_GUNICORN_TIMEOUT=${API_GUNICORN_TIMEOUT} \
		KUMA_CPU_LIMIT=${API_CPU_LIMIT} \
		KUMA_MEMORY_LIMIT=${API_MEMORY_LIMIT} \
		KUMA_CPU_REQUEST=${API_CPU_REQUEST} \
		KUMA_MEMORY_REQUEST=${API_MEMORY_REQUEST} \
		j2 kuma.deploy.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-api:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${API_NAME}

k8s-kumascript:
	j2 kumascript.deploy.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-kumascript:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found \
		deploy ${KUMASCRIPT_NAME}

k8s-celery: k8s-celery-workers k8s-celery-beat k8s-celery-cam

k8s-delete-celery: k8s-delete-celery-workers k8s-delete-celery-beat \
				   k8s-delete-celery-cam

k8s-celery-workers:
	env KUMA_NAME=${CELERY_WORKERS_NAME} \
		KUMA_REPLICAS=${CELERY_WORKERS_REPLICAS} \
		KUMA_CPU_LIMIT=${CELERY_WORKERS_CPU_LIMIT} \
		KUMA_MEMORY_LIMIT=${CELERY_WORKERS_MEMORY_LIMIT} \
		KUMA_CPU_REQUEST=${CELERY_WORKERS_CPU_REQUEST} \
		KUMA_MEMORY_REQUEST=${CELERY_WORKERS_MEMORY_REQUEST} \
		j2 celery.workers.deploy.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-celery-workers:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found \
		deploy ${CELERY_WORKERS_NAME}

k8s-celery-beat:
	env KUMA_NAME=${CELERY_BEAT_NAME} \
		KUMA_REPLICAS=${CELERY_BEAT_REPLICAS} \
		KUMA_CPU_LIMIT=${CELERY_BEAT_CPU_LIMIT} \
		KUMA_MEMORY_LIMIT=${CELERY_BEAT_MEMORY_LIMIT} \
		KUMA_CPU_REQUEST=${CELERY_BEAT_CPU_REQUEST} \
		KUMA_MEMORY_REQUEST=${CELERY_BEAT_MEMORY_REQUEST} \
		j2 celery.beat.deploy.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-celery-beat:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found \
		deploy ${CELERY_BEAT_NAME}

k8s-celery-cam:
	env KUMA_NAME=${CELERY_CAM_NAME} \
		KUMA_REPLICAS=${CELERY_CAM_REPLICAS} \
		KUMA_CPU_LIMIT=${CELERY_CAM_CPU_LIMIT} \
		KUMA_MEMORY_LIMIT=${CELERY_CAM_MEMORY_LIMIT} \
		KUMA_CPU_REQUEST=${CELERY_CAM_CPU_REQUEST} \
		KUMA_MEMORY_REQUEST=${CELERY_CAM_MEMORY_REQUEST} \
		j2 celery.cam.deploy.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-celery-cam:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found \
		deploy ${CELERY_CAM_NAME}

# These tasks don't have file targets
.PHONY: aws-create-mysql-vol aws-describe-mysql-vols k8s-services \
		k8s-delete-services k8s-ns k8s-delete-ns k8s-pv-shared \
		k8s-delete-pv-shared k8s-pvc-shared k8s-delete-pvc-shared \
		k8s-shared-storage k8s-delete-shared-storage k8s-mysql-storage \
		k8s-delete-mysql-storage k8s-web-svc k8s-delete-web-svc k8s-api-svc \
		k8s-delete-api-svc k8s-kumascript-svc k8s-delete-kumascript-svc \
		k8s-mysql-svc k8s-delete-mysql-svc k8s-deployments \
		k8s-delete-deployments k8s-mysql k8s-delete-mysql k8s-web \
		k8s-delete-web k8s-api k8s-delete-api k8s-kumascript \
		k8s-delete-kumascript k8s-celery k8s-delete-celery k8s-celery-workers \
		k8s-delete-celery-workers k8s-celery-beat k8s-delete-celery-beat \
		k8s-celery-cam k8s-delete-celery-cam
