export TARGET_ENVIRONMENT=dev
export K8S_NAMESPACE=mdn-${TARGET_ENVIRONMENT}
export AWS_REGION=us-west-2

## Deployment info
export SUMO_WEB_REPLICAS=3

## Memory/CPU limits
export SUMO_CPU_REQUEST=100m
export SUMO_CPU_LIMIT=2m
export SUMO_MEMORY_REQUEST=256Mi
export SUMO_MEMORY_LIMIT=1Gi

## Environment
export SUMO_ENV_ALLOWED_HOSTS=sumo-dev.frankfurt.moz.works,dev.sumo.moz.works
export SUMO_ENV_AXES_BEHIND_REVERSE_PROXY=True
export SUMO_ENV_CELERY_ALWAYS_EAGER=True
export SUMO_ENV_CSRF_COOKIE_SECURE=True
export SUMO_ENV_DEBUG=False
export SUMO_ENV_DOMAIN=localhost
export SUMO_ENV_ENABLE_WHITENOISE=True
export SUMO_ENV_ENGAGE_ROBOTS=False
export SUMO_ENV_ES_LIVE_INDEXING=True
export SUMO_ENV_ES_USE_SSL=True
export SUMO_ENV_HTTPS=True
export SUMO_ENV_MEDIA_URL=https://dev-cdn.sumo.mozilla.net/
export SUMO_ENV_PIPELINE_ENABLED=True
export SUMO_ENV_PORT=8000
export SUMO_ENV_READ_ONLY=True
export SUMO_ENV_SESSION_COOKIE_SECURE=True
export SUMO_ENV_SITE_URL=http://sumo-dev.frankfurt.moz.works
export SUMO_ENV_STAGE=False
