# MozMEAO Block AWS K8s cron

## Building

The `build.sh` script in the current directory will build a Docker image and push it to [quay.io](https://quay.io/repository/mozmar/blockaws).

## Installing

The `block-aws-cron.yaml` file creates a `meaocron` namespace, `blockaws` ServiceAccount, ClusterRole, ClusterRoleBinding and a Secret resource containing a [Deadmanssnitch](http://deadmanssnitch.com/) URL to ping.

Before installing, you MUST update the `DMS_URL` in the Secret block of `block-aws-cron.yaml`. **DO NOT COMMIT THIS FILE ONCE MODIFIED**.


```shell
    kubectl -n meaocron apply -f ./block-aws-cron.yaml
```
