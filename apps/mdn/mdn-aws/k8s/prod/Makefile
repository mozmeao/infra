export AWS_REGION ?= us-west-2
export PV_SHARED_NAME ?= mdn-kuma-shared
export PV_SHARED_CAPACITY ?= 1000Gi
export PV_SHARED_RECLAIM_POLICY ?= Retain
export PV_SHARED_MOUNT_PATH ?= /mdn-dev
export PV_SHARED_ARN ?= fs-1b4cfe52.efs.us-east-1.amazonaws.com
export MYSQL_NAME ?= mysql
export MYSQL_IMAGE ?= quay.io/mozmar/mdn-mysql
export MYSQL_IMAGE_TAG ?= latest
export MYSQL_IMAGE_PULL_POLICY ?= IfNotPresent
export MYSQL_STORAGE_SIZE ?= 40Gi
export MYSQL_STORAGE_RECLAIM_POLICY ?= Retain
export MYSQL_STORAGE_EBS_ARN ?= vol-0ddfa112775841355
export MYSQL_USER ?= kuma
export MYSQL_PASSWORD ?= kuma
export MYSQL_ROOT_PASSWORD ?= kuma
export MYSQL_DATABASE ?= developer_mozilla_org
export K8S_NAMESPACE ?= mdn-dev
export API_NAME ?= api
export API_REPLICAS ?= 1
export API_GUNICORN_WORKERS ?= 4
export API_GUNICORN_TIMEOUT ?= 120
export WEB_NAME ?= web
export WEB_REPLICAS ?= 1
export WEB_GUNICORN_WORKERS ?= 4
export WEB_GUNICORN_TIMEOUT ?= 120
export WORKER_NAME ?= worker
export WORKER_REPLICAS ?= 1
export WORKER_BEAT_NAME ?= beat
export WORKER_BEAT_REPLICAS ?= 1
export KUMA_IMAGE ?= quay.io/mozmar/kuma
export KUMA_IMAGE_TAG ?= 2fcf608
export KUMA_IMAGE_PULL_POLICY ?= IfNotPresent
# "KUMA_MOUNT_PATH" sets the mount path for the claim of the shared volume.
export KUMA_MOUNT_PATH ?= /data/www
# "KUMA_PV_CLAIM_SIZE" controls the size of the claim made against KUMA_PV_NAME.
export KUMA_PV_CLAIM_SIZE ?= 40Gi
export KUMA_PV_NAME ?= ${PV_SHARED_NAME}
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
export KUMA_CELERY_BROKER_URL ?= "redis://mdndevproto.4pxwyy.ng.0001.use1.cache.amazonaws.com:6379/0"
export ELASTICSEARCH_URL ?= elasticsearch:9200
export MEMCACHED_URL ?= mdndevmemcache.4pxwyy.0001.use1.cache.amazonaws.com:1121
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
	    --size 40 \
	    --volume-type gp2 \
		--availability-zone us-west-2a \
		--tag-specifications 'ResourceType=volume,Tags=[{Key=name,Value=mdn-mysql},{Key=purpose,Value=test},{Key=created-by,Value=${USER}}]'

aws-describe-mysql-vols:
	aws ec2 describe-volumes \
		--region ${AWS_REGION} \
	    --filters Name=tag:name,Values="mdn-mysql"

k8s-ns:
	kubectl create ns ${K8S_NAMESPACE}

k8s-pv-shared:
	j2 pv-shared.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-pvc:
	j2 kuma-pvc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-web:
	env KUMA_NAME=${WEB_NAME} \
	    KUMA_REPLICAS=${WEB_REPLICAS} \
		KUMA_GUNICORN_WORKERS=${WEB_GUNICORN_WORKERS} \
		KUMA_GUNICORN_TIMEOUT=${WEB_GUNICORN_TIMEOUT} \
	    j2 kuma.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-api:
	env KUMA_NAME=${API_NAME} \
	    KUMA_REPLICAS=${API_REPLICAS} \
		KUMA_GUNICORN_WORKERS=${API_GUNICORN_WORKERS} \
		KUMA_GUNICORN_TIMEOUT=${API_GUNICORN_TIMEOUT} \
	    j2 kuma.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-workers:
	env KUMA_NAME=${WORKER_NAME} \
	    KUMA_REPLICAS=${WORKER_REPLICAS} \
	    j2 workers.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-beat:
	env KUMA_NAME=${WORKER_BEAT_NAME} \
	    KUMA_REPLICAS=${WORKER_BEAT_REPLICAS} \
	    j2 workers-beat.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-mysql:
	j2 mysql.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-mysql:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pv ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pvc ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found svc ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${MYSQL_NAME}

# Those tasks don't have file targets
.PHONY: k8s-pv-shared k8s-kuma-pvc k8s-kuma-web k8s-kuma-api k8s-kuma-workers k8s-kuma-beat k8s-mysql k8s-delete-mysql
