# MDN Kubernetes Support Guide

> MDN is running on the MozMEAO Portland Kubernetes cluster, if you don't have credentials to access the cluster, reach out to the SRE team on #meao-infra

## Links

High level:

- [MDN Infra home (general)](https://github.com/mozmeao/infra/tree/master/apps/mdn)
- [MDN Infra AWS home](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws)
- [Deploying MDN](https://github.com/mozmeao/infra/blob/master/apps/mdn/mdn-aws/k8s/README.md)

Tech details:

- [MDN backup cron](https://github.com/mozmeao/infra/tree/master/apps/mdn/utils/mdn_backup_cron)
- [MDN K8s deployments/services/secrets/pv/pvc template](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws/k8s)
- [MDN infra - general docs](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws/docs)
- [MDN AWS resource definitions](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws/infra)
    - [Shared resources (S3)](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws/infra/shared)
    - [per-region resources RDS/Redis/Memcached/EFS](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws/infra/multi_region)
- [MDN CDN resource definition](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws/infra/mdn-cdn)
- [Interactive examples hosting](https://github.com/mozmeao/infra/tree/master/apps/mdn/interactive-examples)

## K8s commands

### General

Most examples are using the `kubectl get ...` subcommand. If you'd prefer output that's more readable, you can substitute the `get` subcommand with `describe`:

```
kubectl -n mdn-prod describe pod web-617205580-ckg2t
```

> Listing resources is easier with the `get` subcommand.

To see all MDN pods currently running:

```
kubectl -n mdn-prod get pods
```

To see all pods running and the K8s nodes they are assigned to:

```
kubectl -n mdn-prod get pods -o wide
```

To show yaml for a single pod:

```
kubectl -n mdn-prod get pod web-617205580-ckg2t -o yaml
```

To show all deployments:

```
 kubectl -n mdn-prod get deployments
```

To show yaml for a single deployment:

```
 kubectl -n mdn-prod get deployment api -o yaml
```

Run a bash shell on a MDN pod:

```
kubectl -n mdn-prod exec -it web-617205580-xx53g bash
```

Scaling a deployment:

```
kubectl -n mdn-prod scale --replicas=20 deployment/web
```

Check rolling update status:

```
kubectl -n mdn-prod rollout status deployment/web
```

#### Working with K8s command output

Filtering pods based on a label:

```
kubectl -n mdn-prod -l app=web get pods
```

Getting a list of pods:

```
kubectl -n mdn-prod -l app=web get pods | tail -n +2 | cut -d" " -f 1
```

Processing K8s command json output with jq:

```
kubectl -n mdn-prod get pods -o json | jq -r .items[].metadata.name
```



### K8s Services

List MDN services:

```
kubectl -n mdn-prod get services
NAME         CLUSTER-IP      EXTERNAL-IP        PORT(S)         AGE
api          100.71.55.158   <none>             80/TCP          24d
kumascript   100.68.62.9     <none>             9080/TCP        24d
web          100.64.86.247   a8583e1be9a37...   443:31383/TCP   24d
```

To see load balancer details for the `web` service:

```
kubectl -n mdn-prod describe service web
  # or
kubectl -n mdn-prod get service web -o yaml
```

### Cronjobs

[K8s cronjob docs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

List cronjobs:

```
kubectl -n mdn-prod get cronjobs
```

> If a cronjob is currently running, it will show as a running pod in `kubectl -n mdn-prod get pods`.


To edit a cronjob schedule:

```
kubectl -n mdn-prod edit cronjob mdn-backup-prod
# modify the "schedule" attribute
```

Example schedules:

- `@hourly` - run every hour
- `*/1 * * * *` - run every minute

#### Datadog/Redis crontask

- Docs for the `mdn-backup` crontask are located [here](https://github.com/mozmeao/infra/tree/master/apps/mdn/utils/mdn_backup_cron).
- Docs for the Datadog/Redis cron tasks are located [here](https://github.com/mozmeao/infra/blob/master/apps/mdn/mdn-aws/docs/mdn-dd-redis.md).

### Persistent Volumes

[K8s persistent volume docs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

MDN uses an AWS EFS pvc mounted at `/mdn`


List persistent volumes:

```
kubectl -n mdn-prod get pv
NAME               CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                  STORAGECLASS   REASON    AGE
mdn-shared-prod    1000Gi     RWX           Retain          Bound     mdn-prod/mdn-shared    efs                      24d
mdn-shared-stage   1000Gi     RWX           Retain          Bound     mdn-stage/mdn-shared   efs                      26d
```

List persistent volume claims:

```
kubectl -n mdn-prod get pvc
NAME         STATUS    VOLUME            CAPACITY   ACCESSMODES   STORAGECLASS   AGE
mdn-shared   Bound     mdn-shared-prod   1000Gi     RWX           efs            24d
```

### Secrets

[K8s secrets docs](https://kubernetes.io/docs/concepts/configuration/secret/)

Secret values are base64 encoded when viewed in K8s output. Once setup as an environment variable or mounted file in a pod, the values are base64 decoded automatically.

We use secrets in two different ways:

- specified as environment variables in a deployment spec
  - [example](https://github.com/mozmeao/infra/blob/613e558cccbe1f0e5791dba657c73a4dc11e8b9a/apps/mdn/mdn-aws/k8s/kuma.base.deploy.yaml.j2#L47-L51)
- mounted as a file in the filesystem
    - [example part 1](https://github.com/mozmeao/infra/blob/613e558cccbe1f0e5791dba657c73a4dc11e8b9a/apps/mdn/mdn-aws/k8s/mdn-dd-redis.yaml.j2#L53-L55) (mapping the file to the filesystem)
    - [example part 2](https://github.com/mozmeao/infra/blob/613e558cccbe1f0e5791dba657c73a4dc11e8b9a/apps/mdn/mdn-aws/k8s/mdn-dd-redis.yaml.j2#L72-L77) (specifying the secrets mount)

To list secrets:

```
kubectl -n mdn-prod get secrets
```

To encode a secret value:

```
echo -n "somevalue" | base64
```

> The `-n` flag strips the newline before base64 encoding.
> Values must be specified without newlines, the `base64` command on Linux can take a `-w 0` parameter that outputs without newlines. The `base64` command in Macos Sierra seems to output encoded values without newlines.

### Kubernetes UI

To run the Kubernetes GUI:

```
kubectl proxy
Starting to serve on 127.0.0.1:8001

# open up a web browser to http://127.0.0.1:8001/ui
```


## Monitoring

### New Relic		

- [kuma-prod-portland](https://rpm.newrelic.com/accounts/1299394/applications/34419452)
- [kumascript-prod-portland](https://rpm.newrelic.com/accounts/1299394/applications/34601215)
- [kuma-web-prod-portland](https://rpm.newrelic.com/accounts/1299394/applications/34459612)
- [kuma-backend-prod-portland](https://rpm.newrelic.com/accounts/1299394/applications/34601198)	
		
### Datadog		

- [MDN Prod Redis (Celery)](https://app.datadoghq.com/dash/373636/mdn-prod-redis?live=true&page=0&is_auto=false&from_ts=1507298951634&to_ts=1507302551634&tile_size=m)
- [MySQL (RDS)](https://app.datadoghq.com/screen/integration/aws_rds_mysql?tpl_var_dbinstanceidentifier=mdn-prod)
- [MemcacheD](https://app.datadoghq.com/screen/integration/aws_elasticache_memcached?tpl_var_cluster_id=mdn-memcached-prod)	
- [Redis](https://app.datadoghq.com/screen/integration/aws_elasticache_redis?tpl_var_cluster_id=mdn-redis-prod-001) (select from primary/secondary nodes in the filter)
- [K8s running containers](https://app.datadoghq.com/containers?columns=container_name,container_cpu,container_memory,container_net_sent_bps,container_net_rcvd_bps,container_status,container_created&options=normalizeCPU&sort=container_memory,DESC&tags=kube_namespace%3Amdn-prod)	
- [K8s running containers by deployment](https://app.datadoghq.com/containers?columns=container_name,container_cpu,container_memory,container_net_sent_bps,container_net_rcvd_bps,container_status,container_created&options=normalizeCPU&sort=container_memory,DESC&tags=kube_namespace%3Amdn-prod&groups=kube_deployment)
- [K8s (general)](https://app.datadoghq.com/screen/integration/kubernetes?tpl_var_namespace=mdn-prod&tpl_var_scope=kubernetescluster%3Aportland.moz.works)	
		
### AWS		

[AWS MDN-prod resource group](https://resources.console.aws.amazon.com/r/group/5)	
## Operations

### Manually adding/removing K8s Portland cluster nodes

1. login to the AWS console
2. ensure you are in the `Oregon` region
3. search for and select the `EC2` service in the AWS console
4. select `Auto Scaling Groups` from the navigation on the left side of the page
5. click on the `nodes.portland.moz.works` row to select it
6. from the `Actions` menu (close to the top of the page), click `Edit`
7. the `Details` tab for the ASG should appear, set the appropriate `Min`, `Desired` and `Max` values.
    1. it's probably good to set `Min` and `Desired` to the same value in case the cluster autoscaler decides to scale down the cluster smaller than the `Min`.
8. click `Save`
9. if you click on `Instances` from the navigation on the left side of the page, you can see the new instances that are starting/stopping.
10. you can see when the nodes join the K8s cluster with the following command:

```
watch 'kubectl get nodes | tail -n +2 | grep -v master | wc -l'
```

> The number that is displayed should eventually match your ASG `Desired` value. Note this value only includes K8s workers.

### Blocking an IP address

1. login to the AWS console
2. ensure you are in the `Oregon` region
3. search for and select the `VPC` service in the AWS console
4. select `Network ACLs` from the navigation on the left side of the page
5. select the row containing the `portland.moz.works` VPC
6. click on the `Inbound Rules` tab
7. click `Edit`
8. click `Add another rule`
9. for `Rule#`, select a value < 100 and > 0
10. for `Type`, select `All Traffic`
11. for `Source`, enter the IP address in CIDR format. To block a single IP, append `/32` to the IP address.
    1. example: `196.52.2.54/32`    
12. for `Allow / Deny`, select `DENY`
13. click `Save`

There are limits that apply to using VPC ACLs documented [here](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Appendix_Limits.html#vpc-limits-nacls).

