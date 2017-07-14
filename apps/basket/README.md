# Basket Provisioning

This directory contains Terraform files to provision Basket resources.

Initially, we only have dev/stage/prod SQS queues for deleted messages.

# Applying

```shell
cd ./infra/multi_region/portland
./provision.sh
```


#### Environment setup

In additional to the standard set of app variables (which can be found in our private
repo), set the following values:

- `DATABASE_URL`
- `DEIS_DOMAIN`
- `NEW_RELIC_APP_NAME`
- `REDIS_URL`
- `STATS_PREFIX`

### Project Source

https://github.com/mozmar/basket
