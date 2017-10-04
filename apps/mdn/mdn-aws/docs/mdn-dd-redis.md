
# Datadog Redis collector for MDN queues

MDN uses Redis as the message transport for Celery, to store tasks that are run
in the background. Each Celery queue is stored as a list in Redis. By tracking
the length of these lists in Datadog, we can identify trends over time, and
alert staff when queued tasks are overwhelming the processing capacity.

### How does this work?

#### Secrets

The secrets titled `datadog-secrets` has 2 key/value pairs: `API_KEY` and `REDIS_CONFIG_FILE`. 

`API_KEY` is a simple base64 encoded value:

```
echo -n "some_api_key_value" | base64
```

`REDIS_CONFIG_FILE` is the base64 encoded contents of the [Datadog Redis configuration](https://docs.datadoghq.com/integrations/redisdb/):

```
cat our_mdn_k8s_secret_repo/k8s/secrets/redisdb.prod.yaml | base64 -w0
# we must specify -w0 to base64 to prevent newlines splitting the value/
```

> Note that the `base64` parameters are different between OSX and Linux. In these examples, I'm using base64 from a Debian Linux install.

#### Datadog Agent Container

The deployment uses [this Docker image](https://github.com/DataDog/docker-dd-agent). The documentation states that files placed in the `/conf.d` directory will be copied to the appropriate Datadog Agent directory upon startup. The snippet from the deployment below shows how the secret is specified as a volume, and then mounted in the `/conf.d` directory. Upon startup, the Datadog agent copies this config file and starts the Redis collector.

```
    ...
    volumeMounts:
      ...
      - name: datadog-secrets
        mountPath: "/conf.d"
        readOnly: true

    ...
      volumes:
        ...
        - name: datadog-secrets
          secret:
              secretName: "datadog-secrets"
              items:
                - key: REDIS_CONFIG_FILE
                  path: redisdb.yaml
```

More info on the Datadog Redis integration can be found [here](https://docs.datadoghq.com/integrations/redisdb/)

More info on Kubernetes secrets can be found [here](https://kubernetes.io/docs/concepts/configuration/secret/)

#### Datadog Redis configuration file

There are a few values to note in the `redisdb.yaml` file. 

- `host` specifies the hostname of the Elasticache cluster. Note that we must be in the same region/VPC as the Redis cluster for the agent to access Redis stats.
- `keys` specifies the Redis queues that we're interested in monitoring
- `warn_on_missing_keys` we set this to `False` as queues are not created until used.
- `tags` specifies a single tag for now: `mdn_redis_prod_us_west_2`. This allows us to create DD dashboards that access only the MDN prod Redis cluster. 

An example `redisdb.yaml` file is located [here](https://github.com/Datadog/integrations-core/blob/master/redisdb/conf.yaml.example).

#### Datadog K8s deployment yaml

The Datadog Deployment was generated from [this page](https://app.datadoghq.com/account/settings#agent/kubernetes), which by default specifies a DaemonSet. Simply changing the `kind` value from `DaemonSet` to `Deployment` allows us to deploy a single pod. 

> Note: the yaml generated in the link above contains our `API_KEY` value, DO NOT commit this value to Git.


### Datadog Agent Status

To troubleshoot or verify the configuration of the agent, you'll need to exec into the appropriate container in Kubernetes:

```
 # the container will most likely have a different name
kubectl -n mdn-prod exec -it mdn-dd-redis-750008621-f2c8q bash
# show the redis configuration that was copied in as a secret
cat /conf.d/redisdb.yaml
# this file gets copied to /etc/dd-agent/conf.d/redisdb.yaml

# To check overall status of the DD agent:
/etc/init.d/datadog-agent info
# This command will also show if the Redis agent is running
```


### Datadog Dashboard setup

The [MDN Prod Redis](https://app.datadoghq.com/dash/373636/mdn-prod-redis?live=true&page=0&is_auto=false&from_ts=1507135007940&to_ts=1507138607940&tile_size=m) dashboard was created with the following values:

```
redis.key.length key:celery mdn_redis_prod_us_west_2
redis.key.length key:mdn_wiki mdn_redis_prod_us_west_2
redis.key.length key:mdn_purgeable mdn_redis_prod_us_west_2
redis.key.length key:mdn_search mdn_redis_prod_us_west_2
redis.key.length key:emails mdn_redis_prod_us_west_2
```

