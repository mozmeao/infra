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


#### MDN backup cronjob

The cronjob can act either in `PUSH` or `PULL` mode, which is specified as an environment variable in the Cronjob yaml. 

- When in `PUSH` mode, the cronjob is named `mdn-backup-prod`, and files are synchronized from local EFS to S3.
- When in `PULL` mode, the cronjob is named `mdn-restore-prod`, and files are synchronized from S3 to local EFS.


The diagram below shows the MDN regions and PUSH/PULL mode values:

```
┌──────────────┐              ┌──────────┐              ┌──────────────┐
│  us-west-2   │              │    S3    │              │ eu-central-1 │
│  Oregon      │━━PUSH━━━━━━━▶│          │━━━━━━PULL━━━▶│ Frankfurt    │
└──────────────┘              └──────────┘              └──────────────┘
```


##### kubectl client

When connecting to an older K8s cluster, such as Frankfurt, you may need to download an older version of Kubectl that matches the version of the server.

Newer clients connecting to older K8s servers may display error messages such as:

    Error from server (NotFound): the server could not find the requested resource


To determine the K8s server version:

```sh
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"9", GitVersion:"v1.9.1", GitCommit:"3a1c9449a956b6026f075fa3134ff92f7d55f812", GitTreeState:"clean", BuildDate:"2018-01-04T11:52:23Z", GoVersion:"go1.9.2", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"6", GitVersion:"v1.6.4", GitCommit:"d6f433224538d4f9ca2f7ae19b252e6fcb66a3ae", GitTreeState:"clean", BuildDate:"2017-05-19T18:33:17Z", GoVersion:"go1.7.5", Compiler:"gc", Platform:"linux/amd64"}
```

Check the values that are part of `Server Version`. The output above shows `1.6` (or `v.1.6.4`).

Next, download a binary following the instructions located [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/). 

```sh
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubectl
chmod +x ./kubectl
# it may be useful to rename the binary to include K8s version number:
mv ./kubectl ./kubectl1.6.4
```

##### Rebuilding the backup cron image

```sh
cd infra/apps/mdn/utils/mdn_backup_cron/image
./build.sh
```

##### MDN backup troubleshooting

- There is a backup/restore test pod that a developer can instantiate to troubleshoot issues. The deployed backup/restore cronjobs do not need to be deleted in order to use this pod, ***HOWEVER, running the `/mdnsync/mdn_sync.sh` shell script at the same time that the cronjob starts may result in undefined results.*** If you just need to check the filesystem, env vars, etc without running the actual `mdn_sync.sh` script, then all you need is:

```sh
cd infra/apps/mdn/mdn-aws/k8s
CHANGE_MDN_INFRA=1 make k8s-backup-test-pod
kubectl -n mdn-prod exec -it mdn-backup-test bash
# do stuff
CHANGE_MDN_INFRA=1 make k8s-delete-backup-test-pod
```

Otherwise, see the next section on how to delete the backup/restore cronjob(s) and create the test pod.

- To troubleshoot the backup cronjob, first delete the existing cronjob, then create a new pod using the `k8s-backup-test-pod` make target. Once you've verified that the test pod is working correctly, recreate the cronjob.

```sh
cd infra/apps/mdn/mdn-aws/k8s
kubectl -n mdn-prod delete cronjob mdn-backup-prod
kubectl -n mdn-prod get jobs | grep mdn-backup-prod
# Delete any backup related jobs
kubectl -n mdn-prod delete job <SOME_JOB>
CHANGE_MDN_INFRA=1 make k8s-backup-test-pod
kubectl -n mdn-prod exec -it mdn-backup-test bash
# your shell should start with /mdnsync as the current directory
./mdn_sync.sh
CHANGE_MDN_INFRA=1 make k8s-delete-backup-test-pod
``` 

Once you're finished, recreate the cronjob with:

```sh
cd infra/apps/mdn/mdn-aws/k8s
source ./regions/portland/prod.sh
CHANGE_MDN_INFRA=true make k8s-backup-cron
# make sure it appears in this list of cronjobs
kubectl -n mdn-prod get cronjobs
# the aliased version of the command above can also be used:
kc get cronjobs
```

To make the cronjob run more often:

```sh
kubectl -n mdn-prod edit cronjob mdn-backup-prod
# edit the schedule value:
# schedule: '*/1 * * * *'
# the schedule value above runs the cronjob once a minute
```

> this is useful to see the cronjob run once, then tweak the `schedule` value back to `@hourly`.


##### MDN restore troubleshooting

> Please see the "kubectl client" note above when interacting with older clusters.

The `mdn-restore-prod` cronjob is created via:

    CHANGE_MDN_INFRA=true make k8s-restore-cron
    
To delete the cronjob:

    CHANGE_MDN_INFRA=true make 8s-delete-restore-cron
    
Additionally, when deleting the restore cronjob, you'll need to cleanup any `Job` resources as well:

```sh
kubectl -n mdn-prod get jobs | grep restore
kubectl -n mdn-prod delete job <SOME_JOB>
```

Useful commands when working with the restore cronjob:

```sh
kubectl -n mdn-prod get cronjobs mdn-restore-prod -o yaml
kubectl -n mdn-prod get jobs | grep restore
kubectl -n mdn-prod get pods | grep restore
```

##### Dev docs

- Development docs for the `mdn-backup` cronjob are located [here](https://github.com/mozmeao/infra/tree/master/apps/mdn/utils/mdn_backup_cron).


#### Datadog/Redis cronjob

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

### elastic.co

Our hosted Elasticsearch cluster is in the `us-west-2` region of AWS. Elastic.co hosting status can be found on [this](https://cloud-status.elastic.co/) page.


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

### <a name="mdndns"></a>MDN DNS 

```
┌─────────────────────────┐        ┌─────────────────────────┐           ┌─────────────────────────┐   
│                         │        │                         │           │                         │   
│ cdn.mdn.mozilla.net     │        │  developer.mozilla.org  │           │ mdn.mozillademos.org    │   
│                         │        │                         │           │                         │   
└────────────┬────────────┘        └────────────┬────────────┘           └───────────┬─────────────┘   
             │                                  │                                    │                 
             │                                  │                                    │                 
┌────────────▼────────────┐        ┌────────────▼────────────┐           ┌───────────▼─────────────┐   
│                         │        │                         │           │                         │   
│ cdn.mdn.moz.works       │        │ mdn-prod.moz.works      │           │ mdn-demos.moz.works     │   
│ CNAME                   │        │ CNAME                   │           │ CNAME                   │   
└────────────┬────────────┘        └────────────┬────────────┘           └────────────┬────────────┘   
             │                                  │                                     │                
             │                                  │                                     │                
┌────────────▼────────────┐        ┌────────────▼────────────┐           ┌────────────▼────────────┐   
│                         │        │                         │           │                         │   
│ Cloudfront distribution ├────────▶ prod.mdn.moz.works      ◀────┐      │ Cloudfront distribution │   
│                         │        │ CNAME  Traffic policy   │    │      │                         │   
└─────────────────────────┘        └────────────┬────────────┘    │      └────────────┬────────────┘   
                                                │                 │                   │                
                                                │                 │                   │                
                                   ┌────────────▼────────────┐    │      ┌────────────▼───────────────┐
                                   │                         │    │      │                            │
                                   │ us-west-2 ELB           │    └──────│ mdn-demos-origin.moz.works │
                                   │                         │           │ CNAME                      │
                                   └─────────────────────────┘           └────────────────────────────┘
```


### Accessing a MySQL snapshot or cold backup

We take daily snapshots of the mdn-prod RDS instance. Follow the [AWS docs on restoring a DB instance from a DB snapshot](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_RestoreFromSnapshot.html).


The [rds\_backup\_tool](https://github.com/mozmeao/infra/blob/master/tools/aws/rds_backup_tool/README.md) takes full mdn-prod encrypted backups that are stored in S3 (and moved to Glacier after 30 days). To access and decrypt a backup, follow [these](https://github.com/mozmeao/infra/blob/master/tools/aws/rds_backup_tool/README.md#decrypting-a-database-archive) instructions.


### Manual Cluster failover

- **verify the Frankfurt read replica**
    - `eu-central-1` (Frankfurt) has a read-replica of the MDN production database
    - the replica is currently a `db.t2.medium`, while the prod DB is `db.m4.xlarge`
        - this may be ok in maintenance mode, but if you are going to enable write traffic, the instance type must be scaled up. 
            - SRE's performed a manual instance type change on the Frankfurt read-replica, and it took ~10 minutes to change from a `db.t2.medium` to a `db.m4.xlarge`. 
    - although we have alerting in place to notify the SRE team in the event of a replication error, it's a good idea to check the replication status on the RDS details page for the `mdn-prod` MySQL instance.
        - specifically, check the `DB Instance Status`, `Read Replica Source`, `Replication State`, and `Replication Error` values.
    - decide if [promoting the read-replica](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html#USER_ReadRepl.Promote) to a master is appropriate.
        - it's preferrable to have a multi-AZ RDS instance, as we can take snapshots against the failover instance (RDS does this by default in a multi-AZ setup).
        - if data is written to a promoted instance, and failover back to the Portland cluster is desirable, a full DB backup and restore in Portland is required.
        - the replica is automatically rebooted before being promoted to a full instance.
- **ensure image versions are up to date**
    - [This document](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws/k8s) describes how to set and deploy new images.
    - Most MySQL changes should already be replicated to the read-replica, however, if you're reading this, chances are things are broken. Ensure that the DB schema is correct for the iamges you're deploying.
- **manually copy S3 files to EFS**
    - [This script](https://github.com/mozmeao/infra/blob/master/apps/mdn/utils/mdn_backup_cron/image/mdn_sync.sh) can be used to pull files from S3 to EFS.
        - the script must be run from a pod that has the MDN EFS mount
        - the script depends on the AWS cli being installed
        - the `mdn-admin` deployment is a good place to run this script
- **scale cluster and pods**
    - the [prod deployment](https://github.com/mozmeao/infra/tree/master/apps/mdn/mdn-aws/k8s) yaml contains the correct number of replicas for each pod, but just in case:

        ```
        kubectl -n mdn-prod scale --replicas=20 deployment/web
        kubectl -n mdn-prod scale --replicas=4 deployment/api
        etc
        ```
- **DNS**
    - see the [MDN DNS](#mdndns) section for additional details
    - point the `prod.mdn.moz.works` traffic policy at the Frankfurt ELB
    - point `mdn-demos.moz.works` at the Frankfurt ELB
    - Cloudfront shouldn't need any changes, as it's origin is `prod.mdn.moz.works`. 
- **Cluster backup**
    - If the cluster is running in maintanence mode, the backup cronjob does not need to be enabled.
    - In write mode, the [backup cron job](https://github.com/mozmeao/infra/tree/master/apps/mdn/utils/mdn_backup_cron) will need to be manually run as the Frankfurt cluster does not have K8s cronjobs enabled.
        - [This script](https://github.com/mozmeao/infra/blob/master/apps/mdn/utils/mdn_backup_cron/image/mdn_sync.sh) can be used to backup to S3.
            - the script must be run from a pod that has the MDN EFS mount
            - the script depends on the AWS cli being installed
            - the `mdn-admin` deployment is a good place to run this script