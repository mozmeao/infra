#!/usr/bin/env bash
echo '--> Setting environment to DEV in PORTLAND'

export KUBECONFIG=~/.kube/portland.config

# Define defaults for environment variables that personalize the commands.
export TARGET_ENVIRONMENT=dev
export K8S_NAMESPACE=mdn-${TARGET_ENVIRONMENT}
export AWS_REGION=us-west-2

# Note PVs are available within ALL namespaces, so delimit them with
# the name of the target environment.
export SHARED_PV_NAME=shared-${TARGET_ENVIRONMENT}
export SHARED_PV_SIZE=1000Gi
export SHARED_PV_RECLAIM_POLICY=Retain
export SHARED_PV_MOUNT_PATH=/
export SHARED_PV_ARN=fs-667aa3cf.efs.us-west-2.amazonaws.com
export SHARED_PV_STORAGE_CLASS_NAME=efs

export SHARED_PVC_NAME=shared
export SHARED_PVC_SIZE=40Gi

export MYSQL_NAME=mysql
export MYSQL_SERVICE_TYPE=ClusterIP
export MYSQL_SERVICE_PORT=3306
export MYSQL_SERVICE_TARGET_PORT=mysql
export MYSQL_SERVICE_PROTOCOL=TCP
export MYSQL_IMAGE=quay.io/mozmar/mdn-mysql
export MYSQL_IMAGE_TAG=latest
export MYSQL_IMAGE_PULL_POLICY=IfNotPresent
MYSQL_STORAGE_SIZE_IN_GB=40
export MYSQL_STORAGE_SIZE=${MYSQL_STORAGE_SIZE_IN_GB}Gi
export MYSQL_STORAGE_RECLAIM_POLICY=Retain
export MYSQL_STORAGE_EBS_ARN=vol-0ddfa112775841355
export MYSQL_STORAGE_EBS_TYPE=gp2
export MYSQL_STORAGE_EBS_AZ=us-west-2a
export MYSQL_USER=kuma
export MYSQL_PASSWORD=kuma
export MYSQL_ROOT_PASSWORD=kuma
export MYSQL_DATABASE=developer_mozilla_org

export WEB_SERVICE_NAME=web
export WEB_SERVICE_TYPE=LoadBalancer
export WEB_SERVICE_PORT=80
export WEB_SERVICE_TARGET_PORT=8000
export WEB_SERVICE_PROTOCOL=TCP

export API_SERVICE_NAME=api
export API_SERVICE_TYPE=ClusterIP
export API_SERVICE_PORT=80
export API_SERVICE_TARGET_PORT=8000
export API_SERVICE_PROTOCOL=TCP

export KUMASCRIPT_SERVICE_NAME=kumascript
export KUMASCRIPT_SERVICE_TYPE=ClusterIP
export KUMASCRIPT_SERVICE_PORT=9080
export KUMASCRIPT_SERVICE_TARGET_PORT=9080
export KUMASCRIPT_SERVICE_PROTOCOL=TCP

export MEMCACHED_URL=mdn-dev-memcached.9zzabg.cfg.usw2.cache.amazonaws.com:11211

export ELASTICSEARCH_URL=elasticsearch:9200

export WEB_NAME=web
export WEB_REPLICAS=1
export WEB_GUNICORN_WORKERS=4
export WEB_GUNICORN_TIMEOUT=120
export WEB_CPU_LIMIT=2
export WEB_CPU_REQUEST=100m
export WEB_MEMORY_LIMIT=16Gi
export WEB_MEMORY_REQUEST=256Mi

export API_NAME=api
export API_REPLICAS=1
export API_GUNICORN_WORKERS=4
export API_GUNICORN_TIMEOUT=120
export API_CPU_LIMIT=2
export API_CPU_REQUEST=100m
export API_MEMORY_LIMIT=16Gi
export API_MEMORY_REQUEST=256Mi

export CELERY_WORKERS_NAME=celery-worker
export CELERY_WORKERS_REPLICAS=1
export CELERY_WORKERS_CPU_LIMIT=2
export CELERY_WORKERS_CPU_REQUEST=100m
export CELERY_WORKERS_MEMORY_LIMIT=16Gi
export CELERY_WORKERS_MEMORY_REQUEST=256Mi
export CELERY_WORKERS_CONCURRENCY=4
export CELERY_WORKERS_QUEUES=mdn_purgeable,mdn_search,mdn_emails,mdn_wiki,celery

export CELERY_BEAT_NAME=celery-beat
export CELERY_BEAT_REPLICAS=1
export CELERY_BEAT_CPU_LIMIT=2
export CELERY_BEAT_CPU_REQUEST=100m
export CELERY_BEAT_MEMORY_LIMIT=16Gi
export CELERY_BEAT_MEMORY_REQUEST=256Mi

export CELERY_CAM_NAME=celery-cam
export CELERY_CAM_REPLICAS=1
export CELERY_CAM_CPU_LIMIT=2
export CELERY_CAM_CPU_REQUEST=100m
export CELERY_CAM_MEMORY_LIMIT=16Gi
export CELERY_CAM_MEMORY_REQUEST=256Mi

export KUMASCRIPT_NAME=kumascript
export KUMASCRIPT_REPLICAS=1
export KUMASCRIPT_CONTAINER_PORT=${KUMASCRIPT_SERVICE_TARGET_PORT}
export KUMASCRIPT_IMAGE=quay.io/mozmar/kumascript
export KUMASCRIPT_IMAGE_TAG=latest
export KUMASCRIPT_IMAGE_PULL_POLICY=IfNotPresent
export KUMASCRIPT_CPU_LIMIT=2
export KUMASCRIPT_CPU_REQUEST=100m
export KUMASCRIPT_MEMORY_LIMIT=16Gi
export KUMASCRIPT_MEMORY_REQUEST=256Mi
export KUMASCRIPT_DOCUMENT_URL_TEMPLATE=http://${API_NAME}/en-US/docs/{path}?raw=1
export KUMASCRIPT_MEMCHACHED_URL=${MEMCACHED_URL}

export KUMA_IMAGE=quay.io/mozmar/kuma
export KUMA_IMAGE_TAG=2fcf608
export KUMA_IMAGE_PULL_POLICY=IfNotPresent
# "KUMA_MOUNT_PATH" sets the mount path for the claim of the shared volume.
export KUMA_MOUNT_PATH=/www
export KUMA_DEBUG="True"
export KUMA_DEBUG_TOOLBAR="False"
export KUMA_PROTOCOL="https://"
export KUMA_DOMAIN=developer.mozilla.org
export KUMA_SITE_URL="https://developer.mozilla.org"
export KUMA_ACCOUNT_DEFAULT_HTTP_PROTOCOL="https"
export KUMA_ALLOWED_HOSTS="*"
export KUMA_SESSION_COOKIE_SECURE="True"
export KUMA_WEB_CONCURRENCY="4"
export KUMA_MAINTENANCE_MODE="False"
export KUMA_CSRF_COOKIE_SECURE="True"
export KUMA_CELERY_BROKER_URL=redis://mdndevredis.9zzabg.0001.usw2.cache.amazonaws.com:6379/0
export KUMA_URL_TEMPLATE_FOR_KUMASCRIPT=http://${KUMASCRIPT_NAME}:${KUMASCRIPT_PORT}/docs/{path}
