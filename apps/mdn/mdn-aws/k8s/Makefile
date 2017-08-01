# Define defaults for environment variables that personalize the commands.
export TARGET_ENVIRONMENT ?= dev
export K8S_NAMESPACE ?= mdn-${TARGET_ENVIRONMENT}
export AWS_REGION ?= us-west-2
export PV_SHARED_NAME ?= shared
export PV_SHARED_CAPACITY ?= 1000Gi
export PV_SHARED_RECLAIM_POLICY ?= Retain
export PV_SHARED_MOUNT_PATH ?= /
export PV_SHARED_ARN ?= fs-a313ca0a.efs.us-west-2.amazonaws.com
export PV_SHARED_STORAGE_CLASS_NAME ?= efs
export MYSQL_NAME ?= mysql
export MYSQL_IMAGE ?= quay.io/mozmar/mdn-mysql
export MYSQL_IMAGE_TAG ?= latest
export MYSQL_IMAGE_PULL_POLICY ?= IfNotPresent
MYSQL_STORAGE_SIZE_IN_GB ?= 40
export MYSQL_STORAGE_SIZE ?= ${MYSQL_STORAGE_SIZE_IN_GB}Gi
export MYSQL_STORAGE_RECLAIM_POLICY ?= Retain
export MYSQL_STORAGE_EBS_ARN ?= vol-0ddfa112775841355
export MYSQL_STORAGE_EBS_TYPE ?= gp2
export MYSQL_STORAGE_EBS_AZ ?= us-west-2a
export MYSQL_USER ?= kuma
export MYSQL_PASSWORD ?= kuma
export MYSQL_ROOT_PASSWORD ?= kuma
export MYSQL_DATABASE ?= developer_mozilla_org
export API_NAME ?= api
export API_REPLICAS ?= 1
export API_GUNICORN_WORKERS ?= 4
export API_GUNICORN_TIMEOUT ?= 120
export API_CPU_LIMIT ?= 2
export API_CPU_REQUEST ?= 100m
export API_MEMORY_LIMIT ?= 16Gi
export API_MEMORY_REQUEST ?= 256Mi
export WEB_NAME ?= web
export WEB_REPLICAS ?= 1
export WEB_GUNICORN_WORKERS ?= 4
export WEB_GUNICORN_TIMEOUT ?= 120
export WEB_CPU_LIMIT ?= 2
export WEB_CPU_REQUEST ?= 100m
export WEB_MEMORY_LIMIT ?= 16Gi
export WEB_MEMORY_REQUEST ?= 256Mi
export WORKER_NAME ?= worker
export WORKER_REPLICAS ?= 1
export WORKER_CPU_LIMIT ?= 2
export WORKER_CPU_REQUEST ?= 100m
export WORKER_MEMORY_LIMIT ?= 16Gi
export WORKER_MEMORY_REQUEST ?= 256Mi
export WORKER_BEAT_NAME ?= beat
export WORKER_BEAT_REPLICAS ?= 1
export WORKER_BEAT_CPU_LIMIT ?= 2
export WORKER_BEAT_CPU_REQUEST ?= 100m
export WORKER_BEAT_MEMORY_LIMIT ?= 16Gi
export WORKER_BEAT_MEMORY_REQUEST ?= 256Mi
export KUMA_IMAGE ?= quay.io/mozmar/kuma
export KUMA_IMAGE_TAG ?= 2fcf608
export KUMA_IMAGE_PULL_POLICY ?= IfNotPresent
# "KUMA_MOUNT_PATH" sets the mount path for the claim of the shared volume.
export KUMA_MOUNT_PATH ?= /www
# "KUMA_PV_CLAIM_SIZE" controls the size of the claim made against KUMA_PV_NAME.
export KUMA_PVC_NAME ?= shared
export KUMA_PVC_SIZE ?= 40Gi
export KUMA_PVC_TARGET_VOLUME ?= ${PV_SHARED_NAME}
export KUMA_PVC_TARGET_STORAGE_CLASS ?= ${PV_SHARED_STORAGE_CLASS_NAME}
export KUMA_DEBUG ?= "False"
export KUMA_DEBUG_TOOLBAR ?= "False"
export KUMA_PROTOCOL ?= "https://"
export KUMA_DOMAIN ?= developer.mozilla.org
export KUMA_SITE_URL ?= "https://developer.mozilla.org"
export KUMA_ACCOUNT_DEFAULT_HTTP_PROTOCOL ?= "https"
export KUMA_ALLOWED_HOSTS ?= "*"
export KUMA_SESSION_COOKIE_SECURE ?= "True"
export KUMA_WEB_CONCURRENCY ?= "4"
export KUMA_MAINTENANCE_MODE ?= "False"
export KUMA_CSRF_COOKIE_SECURE ?= "True"
export KUMA_CELERY_BROKER_URL ?= "redis://mdndevredis.9zzabg.0001.usw2.cache.amazonaws.com:6379/0"
export ELASTICSEARCH_URL ?= elasticsearch:9200
export MEMCACHED_URL ?= mdn-dev-memcached.9zzabg.cfg.usw2.cache.amazonaws.com:11211
export KUMASCRIPT_NAME ?= kumascript
export KUMASCRIPT_PORT ?= 9080
export KUMASCRIPT_IMAGE ?= quay.io/mozmar/kumascript
export KUMASCRIPT_IMAGE_TAG ?= latest
export KUMASCRIPT_IMAGE_PULL_POLICY ?= IfNotPresent
export KUMASCRIPT_REPLICAS ?= 1
export KUMASCRIPT_DOCUMENT_URL_TEMPLATE ?= http://${API_NAME}/en-US/docs/{path}?raw=1
export KUMASCRIPT_MEMCHACHED_URL ?= ${MEMCACHED_URL}
export KUMA_URL_TEMPLATE_FOR_KUMASCRIPT ?= http://${KUMASCRIPT_NAME}:${KUMASCRIPT_PORT}/docs/{path}


aws-create-mysql-vol:
	aws ec2 create-volume \
		--region ${AWS_REGION} \
	    --size ${MYSQL_STORAGE_SIZE_IN_GB} \
	    --volume-type ${MYSQL_STORAGE_EBS_TYPE} \
		--availability-zone ${MYSQL_STORAGE_EBS_AZ} \
		--tag-specifications 'ResourceType=volume,Tags=[{Key=name,Value=mdn-mysql},{Key=purpose,Value=${TARGET_ENVIRONMENT}},{Key=created-by,Value=${USER}}]'

aws-describe-mysql-vols:
	aws ec2 describe-volumes \
		--region ${AWS_REGION} \
	    --filters Name=tag:name,Values="mdn-mysql"

k8s-ns:
	kubectl create ns ${K8S_NAMESPACE}

k8s-delete-ns:
	kubectl delete --ignore-not-found ns ${K8S_NAMESPACE}

k8s-pv-shared:
	j2 pv-shared.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-pv-shared:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pv ${PV_SHARED_NAME}

k8s-pvc-shared:
	j2 kuma-pvc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-pvc-shared:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pvc ${KUMA_PVC_NAME}

k8s-shared: k8s-pv-shared k8s-pvc-shared

k8s-delete-shared: k8s-delete-pvc-shared k8s-delete-pv-shared

k8s-kumascript:
	j2 kumascript.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-kumascript:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found svc ${KUMASCRIPT_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${KUMASCRIPT_NAME}

k8s-web:
	env KUMA_NAME=${WEB_NAME} \
	    KUMA_REPLICAS=${WEB_REPLICAS} \
		KUMA_GUNICORN_WORKERS=${WEB_GUNICORN_WORKERS} \
		KUMA_GUNICORN_TIMEOUT=${WEB_GUNICORN_TIMEOUT} \
		KUMA_CPU_LIMIT=${WEB_CPU_LIMIT} \
		KUMA_MEMORY_LIMIT=${WEB_MEMORY_LIMIT} \
		KUMA_CPU_REQUEST=${WEB_CPU_REQUEST} \
		KUMA_MEMORY_REQUEST=${WEB_MEMORY_REQUEST} \
	    j2 kuma.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-web:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found svc ${WEB_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${WEB_NAME}

k8s-api:
	env KUMA_NAME=${API_NAME} \
	    KUMA_REPLICAS=${API_REPLICAS} \
		KUMA_GUNICORN_WORKERS=${API_GUNICORN_WORKERS} \
		KUMA_GUNICORN_TIMEOUT=${API_GUNICORN_TIMEOUT} \
		KUMA_CPU_LIMIT=${API_CPU_LIMIT} \
		KUMA_MEMORY_LIMIT=${API_MEMORY_LIMIT} \
		KUMA_CPU_REQUEST=${API_CPU_REQUEST} \
		KUMA_MEMORY_REQUEST=${API_MEMORY_REQUEST} \
	    j2 kuma.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-api:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found svc ${API_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${API_NAME}

k8s-workers:
	j2 workers.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-workers:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${WORKER_NAME}

k8s-workers-beat:
	j2 workers-beat.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-workers-beat:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${WORKER_BEAT_NAME}

k8s-mysql:
	j2 mysql.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-mysql:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pv ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pvc ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found svc ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${MYSQL_NAME}

# Those tasks don't have file targets
.PHONY: aws-create-mysql-vol aws-describe-mysql-vols k8s-ns k8s-delete-ns \
	    k8s-pv-shared k8s-delete-pv-shared k8s-pvc-shared \
		k8s-delete-pvc-shared k8s-shared k8s-delete-shared k8s-web \
	    k8s-delete-web k8s-api k8s-delete-api k8s-workers k8s-delete-workers \
		k8s-workers-beat k8s-delete-workers-beat k8s-mysql k8s-delete-mysql
