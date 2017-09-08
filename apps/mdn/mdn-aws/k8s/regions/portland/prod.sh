#!/usr/bin/env bash
echo '--> Setting environment to PROD in PORTLAND'

export KUBECONFIG=~/.kube/portland.config

# Define defaults for environment variables that personalize the commands.
export TARGET_ENVIRONMENT=prod
export K8S_NAMESPACE=mdn-${TARGET_ENVIRONMENT}
export AWS_REGION=us-west-2

# Note PVs are available within ALL namespaces, so delimit them with
# the name of the target environment.
export SHARED_PV_NAME=mdn-shared-${TARGET_ENVIRONMENT}
export SHARED_PV_SIZE=1000Gi
export SHARED_PV_RECLAIM_POLICY=Retain
export SHARED_PV_MOUNT_PATH=/
export SHARED_PV_ARN=
export SHARED_PV_STORAGE_CLASS_NAME=efs

export SHARED_PVC_NAME=mdn-shared
export SHARED_PVC_SIZE=200Gi

export WEB_SERVICE_NAME=web
export WEB_SERVICE_TYPE=LoadBalancer
export WEB_SERVICE_PORT=443
export WEB_SERVICE_TARGET_PORT=8000
export WEB_SERVICE_PROTOCOL=TCP
export WEB_SERVICE_CERT_ARN=arn:aws:acm:us-west-2:236517346949:certificate/acc4b18f-19cf-4977-a8ba-642d8afc831d

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

export WEB_NAME=web
export WEB_REPLICAS=1
export WEB_GUNICORN_WORKERS=4
export WEB_GUNICORN_TIMEOUT=120
export WEB_CPU_LIMIT=4
export WEB_CPU_REQUEST=2
export WEB_MEMORY_LIMIT=16Gi
export WEB_MEMORY_REQUEST=8Gi

export API_NAME=api
export API_REPLICAS=1
export API_GUNICORN_WORKERS=4
export API_GUNICORN_TIMEOUT=120
export API_CPU_LIMIT=4
export API_CPU_REQUEST=2
export API_MEMORY_LIMIT=16Gi
export API_MEMORY_REQUEST=8Gi

export CELERY_WORKERS_NAME=celery-worker
export CELERY_WORKERS_REPLICAS=6
export CELERY_WORKERS_CPU_LIMIT=4
export CELERY_WORKERS_CPU_REQUEST=2
export CELERY_WORKERS_MEMORY_LIMIT=16Gi
export CELERY_WORKERS_MEMORY_REQUEST=8Gi
export CELERY_WORKERS_CONCURRENCY=4
export CELERY_WORKERS_QUEUES=mdn_purgeable,mdn_search,mdn_emails,mdn_wiki,celery

export CELERY_BEAT_NAME=celery-beat
export CELERY_BEAT_REPLICAS=1
export CELERY_BEAT_CPU_LIMIT=1
export CELERY_BEAT_CPU_REQUEST=500m
export CELERY_BEAT_MEMORY_LIMIT=2Gi
export CELERY_BEAT_MEMORY_REQUEST=256Mi

export CELERY_CAM_NAME=celery-cam
export CELERY_CAM_REPLICAS=1
export CELERY_CAM_CPU_LIMIT=1
export CELERY_CAM_CPU_REQUEST=500m
export CELERY_CAM_MEMORY_LIMIT=4Gi
export CELERY_CAM_MEMORY_REQUEST=1Gi

export KUMASCRIPT_NAME=kumascript
export KUMASCRIPT_REPLICAS=1
export KUMASCRIPT_CONTAINER_PORT=${KUMASCRIPT_SERVICE_TARGET_PORT}
export KUMASCRIPT_IMAGE=quay.io/mozmar/kumascript
export KUMASCRIPT_IMAGE_TAG=latest
export KUMASCRIPT_IMAGE_PULL_POLICY=IfNotPresent
export KUMASCRIPT_CPU_LIMIT=4
export KUMASCRIPT_CPU_REQUEST=2
export KUMASCRIPT_MEMORY_LIMIT=16Gi
export KUMASCRIPT_MEMORY_REQUEST=8Gi
export KUMASCRIPT_DOCUMENT_URL_TEMPLATE=http://${API_NAME}/en-US/docs/{path}?raw=1

export KUMA_IMAGE=quay.io/mozmar/kuma
export KUMA_IMAGE_TAG=f44ba6e
export KUMA_IMAGE_PULL_POLICY=IfNotPresent
export KUMA_MEDIA_ROOT=/mdn/www
# "KUMA_MOUNT_PATH" sets the mount path for the claim of the shared volume.
export KUMA_MOUNT_PATH=/mdn
export KUMA_DEBUG="False"
export KUMA_DEBUG_TOOLBAR="False"
export KUMA_PROTOCOL="https://"
export KUMA_DOMAIN=developer.mozilla.org
export KUMA_ATTACHMENT_HOST=mdn.mozillademos.org
export KUMA_ACCOUNT_DEFAULT_HTTP_PROTOCOL="https"
export KUMA_ALLOWED_HOSTS="developer.mozilla.org, developer.cdn.mozilla.net, mdn.mozillademos.org"
export KUMA_SESSION_COOKIE_SECURE="True"
export KUMA_WEB_CONCURRENCY="4"
export KUMA_MAINTENANCE_MODE="False"
export KUMA_CSRF_COOKIE_SECURE="True"
export KUMA_SERVE_LEGACY="True"
export KUMA_LEGACY_ROOT=/mdn/www
