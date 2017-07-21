# bedrock provisioning

## Additional post-installation steps

If provisioning a new region:

- add `A`/`AAAA` records for bedrock-<env>.<cluster>.moz.works pointing to the specific ELB
  - replacing <env> and <cluster> with appropriate values
  - ex: `bedrock-prod.frankfurt.moz.works`
- create Route 53 healthchecks
  - stage should _not_ raise alerts
  - prod _should_ raise alerts
- The clock process is scaled in `./scale.sh`, which will run database migrations. There is also a [sync-all.sh](https://github.com/mozilla/bedrock/blob/master/bin/sync-all.sh) script that can be run inside on of the running bedrock containers in the cluster. Run this if you don't want to wait for the clock cron task(s) to run.

- add the region to [www-config](https://github.com/mozmeao/www-config)

- Set environment-specific environment variables:
  - `DEIS_DOMAIN`
  - `DATABASE_URL`
  - `NEW_RELIC_APP_NAME`

### Project Source

https://github.com/mozilla/bedrock

