export PV_SHARED_NAME ?= mdn-kuma-shared
export PV_SHARED_CAPACITY ?= 1000Gi
export PV_SHARED_RECLAIM_POLICY ?= Retain
export PV_SHARED_MOUNT_PATH ?= /mdn-dev
export PV_SHARED_ARN ?= fs-1b4cfe52.efs.us-east-1.amazonaws.com
export MYSQL_NAME ?= mysql
export MYSQL_IMAGE ?= quay.io/mozmar/mdn-mysql
export MYSQL_IMAGE_TAG ?= latest
export MYSQL_IMAGE_PULL_POLICY ?= IfNotPresent
export MYSQL_STORAGE_SIZE ?= 50Gi
export MYSQL_STORAGE_RECLAIM_POLICY ?= Retain
export MYSQL_STORAGE_EBS_ARN ?= vol-03d328b4c516cd557
export MYSQL_USER ?= kuma
export MYSQL_PASSWORD ?= kuma
export MYSQL_ROOT_PASSWORD ?= kuma
export MYSQL_DATABASE ?= developer_mozilla_org
export K8S_NAMESPACE ?= mdn-dev
# "KUMA_REPLICAS" controls replicas for k8s-kuma-web and k8s-kuma-api.
export KUMA_REPLICAS ?= 1
# "KUMA_WORKER_REPLICAS" controls replicas for k8s-kuma-workers.
export KUMA_WORKER_REPLICAS ?= 6
# "KUMA_PV_CLAIM_SIZE" controls the size of the claim made against KUMA_PV_NAME.
export KUMA_PV_CLAIM_SIZE ?= 40Gi
export KUMA_PV_NAME ?= ${PV_SHARED_NAME}
export KUMA_GIT_COMMIT_SHORT ?= 2fcf608
# "KUMA_MOUNT_PATH" sets the mount path for the claim of the shared volume.
export KUMA_MOUNT_PATH ?= /data/www
export KUMA_GUNICORN_WORKERS ?= 4
export KUMA_GUNICORN_TIMEOUT ?= 120
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
export KUMASCRIPT_URL_TEMPLATE ?= http://kumascript:9080/docs/{path}
export MEMCACHED_URL ?= mdndevmemcache.4pxwyy.0001.use1.cache.amazonaws.com:1121


k8s-pv-shared:
	j2 pv-shared.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-pvc:
	j2 kuma-pvc.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-web:
	env KUMA_NAME=web \
	    j2 kuma.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-api:
	env KUMA_NAME=api \
	    j2 kuma.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-workers:
	env KUMA_NAME=worker \
	    j2 workers.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-kuma-beat:
	env KUMA_NAME=beat \
	    j2 beat.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-mysql:
	j2 mysql.yaml.j2 | kubectl apply -n ${K8S_NAMESPACE} -f -

k8s-delete-mysql:
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pv ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found pvc ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found svc ${MYSQL_NAME}
	kubectl delete -n ${K8S_NAMESPACE} --ignore-not-found deploy ${MYSQL_NAME}

# Those tasks don't have file targets
.PHONY: k8s-pv-shared k8s-kuma-pvc k8s-kuma-web k8s-kuma-api k8s-kuma-workers k8s-kuma-beat k8s-mysql k8s-delete-mysql
