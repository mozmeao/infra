# MozMeao Kubernetes install

### Prereqs

- kops
- terraform
- awscli
- request an AWS ACM certificate for:
    - ${KOPS_NAME}
    - *.${KOPS_NAME}
    - viewsourceconf (and any others you may want on the same cert)

The easiest way to run our K8s install is via a [dev node](https://github.com/mozmar/infra/blob/master/k8s/dev_node/README.md).

### Building a new kops cluster (stage 1)

```
cd infra/k8s/install
export KOPS_INSTALLER=$(pwd)

mkdir my_cluster
cd my_cluster
cp $KOPS_INSTALLER/etc/config.sh.template config.sh
# modify config.sh to your liking
```

**At this point, you MUST customize config.sh.**

When you're ready, run the installer:
```
source config.sh
$KOPS_INSTALLER/stage1.sh
```

Two different sets of results of `stage1.sh` are stored in:
 - a) `./out/terraform` (terraform only)
 - b) general kops config stored in an S3 bucket: `$KOPS_STATE_BUCKET`.

#### Node disk sizing

kops doesn't have an easy way to set the node disk size up front, so we'll need to do a few manual things first.

Run the following command:

```
kops edit ig nodes
```

A yaml file will appear in your $EDITOR, you'll need to add the following block to the `spec` section:

```
  rootVolumeSize: 250
  rootVolumeType: gp2
```

followed by:

```
kops update cluster tokyo.moz.works --target terraform
```

#### Single AZ installations

If you're deploying in a region with < 3 availability zones, you'll need to manually create a new subnet in the VPC for the second availability zone listed in the `config.sh` `KOPS_ZONES` value.

Create a file called `out/terraform/subnets.tf`, and copy the `aws_subnet` Terraform resource from `out/terraform/kubernetes.tf` into this file. You *MUST* change the terraform name, resource name, tag name and cidr_block.

For example, for a cluster deployed in `ap-northeast-1`, here's

```
resource "aws_subnet" "ap-northeast-1c-tokyo-moz-works" {
  vpc_id            = "${aws_vpc.tokyo-moz-works.id}"
  cidr_block        = "172.20.64.0/19"
  availability_zone = "ap-northeast-1c"

  tags = {
    KubernetesCluster = "tokyo.moz.works"
    Name              = "ap-northeast-1c.tokyo.moz.works"
  }
}

```

### Provisioning AWS resources

When you're ready to continue, apply the Terraform config:

```
cd out/terraform
terraform plan
terraform apply
```

Wait ~10-20 minutes.

Check your cluster with:

```
 # ensure you're pointing at the correct kops cluster first!
 # take a look at ~/.kube/config and ensure it's
 # not pointing at more than 1 cluster

cp ~/.kube/config ./${KOPS_SHORT_NAME}.kubeconfig
export KUBECONFIG=$(pwd)/${KOPS_SHORT_NAME}.kubeconfig
kubectl config current-context
kubectl get nodes
```


### Enabling K8s cron

- See https://github.com/kubernetes/kops/issues/618

```
kops edit cluster ${KOPS_NAME}
```

Add the following under the `spec` section:

```
  kubeAPIServer:
    runtimeConfig:
      "batch/v2alpha1": "true"
```

> Note: the value `true` MUST appear in double quotes.

Now apply the changes to the cluster:

```
kops rolling-update cluster ${KOPS_NAME} --force --yes
```

It's easiest to run this before the cluster has any pods/services installed and running.

### Disable public SSH

```
cd k8s/tools
./k8s_ssh_security.sh --disable
```


### Installing monitoring services (stage2)

This step installs Mig, Datadog, New Relic DaemonSets, the k8s dashboard, and Deis Workflow.

You'll need to:

0. clone and **unlock** the `ee-infra-private` repo
1. modify `config.sh` and set `STAGE2_ETC_PATH` to point to the `ee-infra-private/k8s/install/etc` directory.
2. cd to the directory containing config.sh
3. run: `$KOPS_INSTALLER/stage2.sh`

Note: each DaemonSet is installed into it's own namespace: `mig`, `datadog`, `newrelic`, and `deis`.

---
# Post install


### Generating kubeconfig

More info [here](https://github.com/kubernetes/kops/blob/master/docs/tips.md)

```
kops export kubecfg ${NAME}
```

### Using the K8s dashboard

```
# make sure you're in the right context
kubectl config current-context
# run this in a new window and keep it running while you're using the gui
kubectl proxy
```

Open a web browser to [http://localhost:8001/ui](http://localhost:8001/ui)
