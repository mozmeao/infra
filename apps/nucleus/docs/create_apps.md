# Nucleus app setup

deis2 create nucleus-dev --no-remote
deis2 create nucleus-stage --no-remote
deis2 create nucleus-prod --no-remote

deis2 pull quay.io/mozmar/nucleus:3a4dbfe489cc1674742068b38735551711d013e5 -a nucleus-stage
deis2 pull quay.io/mozmar/nucleus:3a4dbfe489cc1674742068b38735551711d013e5 -a nucleus-prod

deis2 limits:set web=150M/300M -a nucleus-stage
deis2 limits:set web=100m/250m --cpu -a nucleus-stage
deis2 autoscale:set web --min=3 --max=5 --cpu-percent=80 -a nucleus-stage

deis2 limits:set web=150M/300M -a nucleus-prod
deis2 limits:set web=100m/250m --cpu -a nucleus-prod
deis2 autoscale:set cmd --min=3 --max=5 --cpu-percent=80 -a nucleus-prod

deis2 config:unset SECURE_SSL_REDIRECT -a nucleus-stage
deis2 config:unset SECURE_SSL_REDIRECT -a nucleus-prod

deis2 config:set  SSL_DISABLE=True -a nucleus-stage
deis2 config:set  SSL_DISABLE=True -a nucleus-prod

deis2 config:set ALLOWED_HOSTS=\* -a nucleus-stage
deis2 config:set ALLOWED_HOSTS=\* -a nucleus-prod

