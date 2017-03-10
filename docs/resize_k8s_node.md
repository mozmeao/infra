## Resizing block storage on K8s worker nodes

This doc coveres resizing block storage on kops/K8s worker nodes. It's a manual operation, and takes ~1-2 hours. 


#### 1. source `config.sh` for your cluster

```
cd ee-infra-private/k8s/clusters/clustername
source config.sh
```

- set `KUBECONFIG` to the correct cluster
- set `DEIS_PROFILE` to the correct cluster


#### 2. scale up any application(s) you have running on the cluster:

```
deis scale cmd=3 -a viewsourceconf
...
```


#### 3. Scale up the deis router:

```
kubectl -n deis edit deployment deis-router
```

change `spec: replicas:` to a higher value.

#### 4. duplicate the `aws_launch_configuration` for nodes

```
cd ./out/terraform
$EDITOR kubernetes.tf
```

Duplicate the `aws_launch_configuration` section for nodes. Here's the resource I'm duplicating for the Tokyo cluster:

```
resource "aws_launch_configuration" "nodes-tokyo-moz-works" {
    name_prefix                 = "nodes.tokyo.moz.works-"
    ...
}
```

Rename the duplicated resource, and change any paramters:

```
resource "aws_launch_configuration" "smaller-nodes-tokyo-moz-works" {
    name_prefix                 = "nodes.tokyo.moz.works-"
    ...
}
```

> keep the `name_prefix` value the same. 

Apply changes for the launch configuration:

```
terraform plan
terraform apply
```

#### 5. update the nodes auto scaling group

Once the new `aws_launch_configuration` is in place, change the `launch_configuration` value on the appropriate `aws_autoscaling_group`:

```
resource "aws_autoscaling_group" "nodes-tokyo-moz-works" {
    name                 = "nodes.tokyo.moz.works"
   launch_configuration = "${aws_launch_configuration.smaller-nodes-tokyo-moz-works.id}"
   ...
   }
```
> The `launch_configuration` value has changed to point to the new `aws_launch_configuration`


Apply ASG changes:

```
terraform plan
terraform apply
```

At this point, any new nodes added to the cluster will have an updated disk size, but nodes that don't match the launch configuration will NOT be automatically destroyed. We'll scale the cluster up, and the slowly back down to let the ASG kill nodes from the previos launch configuration.

#### 6. scale the nodes in the cluster

Set `TOTAL_NODES` to 2 * nodecount.

```
TOTAL_NODES=6
ASG_NAME="nodes.${KOPS_NAME}"
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "${ASG_NAME}" \
    --max-size ${TOTAL_NODES} \
    --region ${KOPS_REGION}

aws autoscaling set-desired-capacity \
    --auto-scaling-group-name "${ASG_NAME}" \
    --desired-capacity ${TOTAL_NODES} \
    --region ${KOPS_REGION}
```

Wait a good 15 minutes for the new nodes to become part of the cluster. 
Use the following to determine node state:

```
watch 'kubectl get nodes | grep -v master | tail -n +2 | wc -l'
```

#### 7. scale down the cluster

- disable New Relic alerts for each affected node
- change `TOTAL_NODES` by -1 at a time, 

Run the following script, decreasing `TOTAL_NODES` until you reach the desired number. Since we've scaled up the applications and Deis router, there should be a minimal impact to running apps as long as you scale down a node at a time. The ASG will only terminate nodes that don't use the newer launch configuration.

```
TOTAL_NODES=5
ASG_NAME="nodes.${KOPS_NAME}"
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "${ASG_NAME}" \
    --max-size ${TOTAL_NODES} \
    --region ${KOPS_REGION}

aws autoscaling set-desired-capacity \
    --auto-scaling-group-name "${ASG_NAME}" \
    --desired-capacity ${TOTAL_NODES} \
    --region ${KOPS_REGION}
```

#### 8. Cleanup

- reenable any New Relic alerts
- commit any changes to `ee-infra-private`

