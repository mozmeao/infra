# MozMEAO Block AWS K8s cron

Block AWS metadata server access using K8s network policies.

## Building

The `build.sh` script in the current directory will build a Docker image and push it to [quay.io](https://quay.io/repository/mozmar/blockaws).

## Secret Installation

You can skip this step

Before installing, you MUST update the `DMS_URL` in the Secret block of `secret.yaml`. **DO NOT COMMIT THIS FILE ONCE MODIFIED**.
```shell
    kubectl -n meaocron apply -f ./block-aws-cron.yaml
```

## Installing
The `block-aws-cron.yaml` file creates a `meaocron` namespace, `blockaws` ServiceAccount, ClusterRole, ClusterRoleBinding and a Secret resource containing a [Deadmanssnitch](http://deadmanssnitch.com/) URL to ping.

```shell
    kubectl -n meaocron apply -f ./block-aws-cron.yaml
```

You should only have to do this once per cluster generally.  The secret only needs to be updated if you've made a change to DMS. Using `block-aws-cron-secret.yaml.dist` as a template, populate the `DMS_URL` value and apply to the cluster/namespace.

```shell
    kubectl -n meaocron apply -f /path/to/some-secrets-file.yaml
```

## What this tool does

In general the way that aws permissions work is that they follow the pattern of trying a few ways of getting access, and the first one that doesn't fail is used.  For our instances running in aws the 'iam role' of the instance is early in that list.  After that is aws access keys and secrets.  We have decided to prefer using access keys for individual services (since what a k8s instance needs access to is wider than an individual service. And to prevent services that share instances from being granted the combination of all service access.) By blocking the metadata endpoint in aws, we prevent a service (like bedrock) from using the 'iam role', and then using the iam access key we pass in as a secret.

Alternatives to this are things like kube2iam, which use rbac inside the k8s cluster to limit access to roles and other iam objects that then grant access to aws resources.
