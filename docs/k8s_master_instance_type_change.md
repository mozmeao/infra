## Changing K8s master instance type in AWS

See also:

- https://github.com/kubernetes/kops/blob/master/docs/changing_configuration.md
- https://github.com/kubernetes/kops/blob/master/docs/terraform.md

#### 1. source `config.sh` for your cluster

```
cd ee-infra-private/k8s/clusters/clustername
source config.sh
```

- set `KUBECONFIG` to the correct cluster
- set `DEIS_PROFILE` to the correct cluster

#### 2. Disable alerts

Add the master to the New Relic `Maintenace` group.

#### 3. modify the `aws_launch_configuration` for a single master:

Don't apply this to all master launch configurations at once.

In this example cluster, we are using 3 AZ's, so we'll change the master for `us-east-1b`, apply the change, wait until the new master comes up (in later steps), and then return to this step to work on the next AZ.

##### With Kops state

Start here, replacing the master name with the appropriate value:

```
kops edit ig master-us-east-1b --name=${KOPS_NAME} --state=${KOPS_STATE_STORE}

kops update cluster \
      --name=${KOPS_NAME} \
      --state=${KOPS_STATE_STORE} \
      --out=./out/terraform \
      --target=terraform
```

Plan and apply the changes:

```
terraform plan
terraform apply
```


##### Without Kops state

Or, you can manually edit the Terraform if for some reason you don't have kops state laying around (ahem):

```
cd ./out/terraform
$EDITOR kubernetes.tf
```

Here's an example of the Terraform resource to change:

```
resource "aws_launch_configuration" "master-us-east-1b-masters-virginia-moz-works" {
  name_prefix = "master-us-east-1b.masters.virginia.moz.works-"
  image_id = "ami-4bb3e05c"
  instance_type = "c4.large"
```

Change the instance type to the appropriate value. Here we're changing from a `c4.large` to a `m4.large`:

```
resource "aws_launch_configuration" "master-us-east-1b-masters-virginia-moz-works" {
  name_prefix = "master-us-east-1b.masters.virginia.moz.works-"
  image_id = "ami-4bb3e05c"
  instance_type = "m4.large"
```

Plan and apply the changes:

```
terraform plan
terraform apply
```

#### 4. scale the master ASG up to start new instance types

```
KOPS_ZONE=us-east-1b

# scale up and wait for new node to start
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "master-${KOPS_ZONE}.masters.${KOPS_NAME}" \
    --max-size 2 \
    --region ${KOPS_REGION}

aws autoscaling set-desired-capacity \
    --auto-scaling-group-name "master-${KOPS_ZONE}.masters.${KOPS_NAME}" \
    --desired-capacity 2 \
    --region ${KOPS_REGION}

```

#### 5. Wait until new master comes up, bring old master down

Wait until the instance is fully started, then scale the ASG down to get rid of the instance with the old instance type:

```
# once new node has started, scale down
aws autoscaling set-desired-capacity \
    --auto-scaling-group-name "master-${KOPS_ZONE}.masters.${KOPS_NAME}" \
    --desired-capacity 1 \
    --region ${KOPS_REGION}

aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "master-${KOPS_ZONE}.masters.${KOPS_NAME}" \
    --max-size 1 \
    --region ${KOPS_REGION}
```

#### 8. Manually update DNS

Until [kubernetes/kops#1938](https://github.com/kubernetes/kops/issues/1938) is resolved, we'll need to manually update Route53 to point to the new master IP.

#### 7. Go back to step 2 for the next AZ

- make sure you disable New Relic alarms. 

#### 8. Cleanup

- reenable any New Relic alerts
- commit any changes to `ee-infra-private`

