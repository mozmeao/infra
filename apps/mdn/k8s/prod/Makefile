export PV_DB_NAME ?= pv-mdn-fast-db
export PV_DB_CAPACITY ?= 50Gi
export PV_DB_RECLAIM_POLICY ?= Retain
export PV_DB_STORAGE_CLASS_NAME ?= mdn-fast-db
export PV_DB_ARN ?= vol-03d328b4c516cd557
export PV_SHARED_NAME ?= pv-mdn-shared
export PV_SHARED_CAPACITY ?= 1000Gi
export PV_SHARED_RECLAIM_POLICY ?= Retain
export PV_SHARED_STORAGE_CLASS_NAME ?= mdn-shared
export PV_SHARED_MOUNT_PATH ?= /mdn-dev
export PV_SHARED_ARN ?= fs-1b4cfe52.efs.us-east-1.amazonaws.com
export MYSQL_IMAGE ?= quay.io/mozmar/mdn-mysql
export MYSQL_IMAGE_TAG ?= latest
export MYSQL_PERSISTENCE_SIZE ?= 100Gi
export MYSQL_RELEASE ?= mdn
export K8S_NAMESPACE ?= mdn-dev
# "KUMA_REPLICAS" controls replicas for k8s-kuma-web and k8s-kuma-api.
export KUMA_REPLICAS ?= 1
# "KUMA_WORKER_REPLICAS" controls replicas for k8s-kuma-workers.
export KUMA_WORKER_REPLICAS ?= 6
# "KUMA_PV_CLAIM_SIZE" controls the size of the claim made against KUMA_PV_NAME.
export KUMA_PV_CLAIM_SIZE ?= 40Gi
export KUMA_PV_NAME ?= pv-mdn-shared
export KUMA_GIT_COMMIT_SHORT ?= ae6b127
# "KUMA_MOUNT_PATH" sets the mount path for the claim of the shared volume.
export KUMA_MOUNT_PATH ?= /app
export KUMA_GUNICORN_WORKERS ?= 4
export KUMA_GUNICORN_TIMEOUT ?= 120
export KUMA_DEBUG ?= False
export KUMA_DEBUG_TOOLBAR ?= False
export KUMA_DOMAIN ?= web
export KUMA_CELERY_BROKER_URL ?= "redis://mdndevproto.4pxwyy.ng.0001.use1.cache.amazonaws.com:6379/0"
export KUMA_ALLOWED_HOSTS ?= "*"
export KUMA_PROTOCOL ?= "http://"
export KUMA_ACCOUNT_DEFAULT_HTTP_PROTOCOL ?= "http"
export KUMA_SESSION_COOKIE_SECURE ?= False
export KUMA_SITE_URL ?= "http://web"
export KUMA_WEB_CONCURRENCY ?= 4
export KUMA_MAINTENANCE_MODE ?= False
export KUMA_CSRF_COOKIE_SECURE ?= True
export ELASTICSEARCH_URL ?= elasticsearch:9200
export KUMASCRIPT_URL_TEMPLATE ?= http://kumascript:9080/docs/{path}
export MEMCACHED_URL ?= mdndevmemcache.4pxwyy.0001.use1.cache.amazonaws.com:1121


k8s-pv-db:
	j2 pv-db.yaml.j2 | kubectl create -n ${K8S_NAMESPACE} -f -

k8s-pv-shared:
	j2 pv-shared.yaml.j2 | kubectl create -n ${K8S_NAMESPACE} -f -

k8s-kuma-pvc:
	j2 kuma-pvc.yaml.j2 | kubectl create -n ${K8S_NAMESPACE} -f -

k8s-kuma-web:
	env KUMA_NAME=web \
	    j2 kuma.yaml.j2 | kubectl create -n ${K8S_NAMESPACE} -f -

k8s-kuma-api:
	env KUMA_NAME=api \
	    j2 kuma.yaml.j2 | kubectl create -n ${K8S_NAMESPACE} -f -

k8s-kuma-workers:
	env KUMA_NAME=worker \
	    j2 workers.yaml.j2 | kubectl create -n ${K8S_NAMESPACE} -f -

k8s-kuma-beat:
	env KUMA_NAME=beat \
	    j2 beat.yaml.j2 | kubectl create -n ${K8S_NAMESPACE} -f -

k8s-mysql-install:
	helm install \
	    --name ${MYSQL_RELEASE} \
		--namespace ${K8S_NAMESPACE} \
		--version 0.2.6 \
		stable/mysql \
		--set image=${MYSQL_IMAGE},imageTag=${MYSQL_IMAGE_TAG},persistence.size=${MYSQL_PERSISTENCE_SIZE}

# Those tasks don't have file targets
.PHONY: k8s-pv-db k8s-pv-shared k8s-kuma-pvc k8s-kuma-web k8s-kuma-api k8s-kuma-workers k8s-kuma-beat k8s-mysql-install
