# MozMEAO Block AWS K8s cron

Block AWS metadata server access using K8s network policies.

## Building

The `build.sh` script in the current directory will build a Docker image and push it to [quay.io](https://quay.io/repository/mozmar/blockaws).

## Installing

The `block-aws-cron.yaml` file creates a `meaocron` namespace, `blockaws` ServiceAccount, ClusterRole and a ClusterRoleBinding resource containing a [Deadmanssnitch](http://deadmanssnitch.com/) URL to ping.

```shell
    kubectl -n meaocron apply -f ./block-aws-cron.yaml
```

Using `block-aws-cron-secret.yaml.dist` as a template, populate the `DMS_URL` value and apply to the cluster/namespace.

```shell
    kubectl -n meaocron apply -f /path/to/some-secrets-file.yaml
```