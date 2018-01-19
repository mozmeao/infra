# MozMeao Kubernetes install

### Prereqs

- `kops`, using the latest version that supports the targeted K8s version
- `kubectl`, using the latest version that supports the targeted K8s version
- `terraform` >= 0.9.8
- `awscli`, latest version
- request an AWS ACM certificate for:
    - ${KOPS_NAME}
    - *.${KOPS_NAME}
- create a new Papertrail group and log destination to use in `config.sh`

## K8s <= 1.7 installation

- see [README-PRE-1.8.md](README-PRE-1.8.md) for more information.

## K8s 1.8+ installation

### Create a config.sh

```
cd infra/k8s/install
export KOPS_INSTALLER=$(pwd)
mkdir my_cluster
cd my_cluster
```

Create a `config.sh` file located in our private repo

```
export KOPS_SHORT_NAME=
export KOPS_DOMAIN=moz.works
export KOPS_NAME="${KOPS_SHORT_NAME}.${KOPS_DOMAIN}"
export KOPS_REGION=us-west-2
export KOPS_NODE_COUNT=2
export KOPS_NODE_SIZE=m4.xlarge
export KOPS_MASTER_SIZE=m4.large
export KOPS_PUBLIC_KEY=/full/path/to/key
export KOPS_ZONES="us-west-2b"
export KOPS_MASTER_ZONES="us-west-2b"
export KOPS_K8S_VERSION="1.8.4"
export KOPS_MASTER_VOLUME_SIZE_GB=250
export KOPS_NODE_VOLUME_SIZE_GB=250
export KOPS_VPC_ID=
# used to allow ssh access into the cluster
export KOPS_SSH_IP=

# s3 buckets
export KOPS_STATE_BUCKET="${KOPS_SHORT_NAME}-kops-state"
export KOPS_STATE_STORE="s3://${KOPS_STATE_BUCKET}"

#populate these if installing FluentD->PaperTrail DaemonSet
export SYSLOG_HOST=""
export SYSLOG_PORT=""
export STAGE2_ETC_PATH=/path/to/private/repo/k8s/install/etc
```


### Create an install.sh

Create an `install.sh` script using the following template. Now is your chance to specify kops configuration values before the cluster is created.

```
#!/bin/bash

aws s3 mb s3://${KOPS_STATE_BUCKET} --region ${KOPS_REGION} || true

kops create cluster ${KOPS_NAME} \
    --authorization=RBAC \
    --cloud aws \
    --kubernetes-version=${KOPS_K8S_VERSION} \
    --master-size=${KOPS_MASTER_SIZE} \
    --master-volume-size=${KOPS_MASTER_VOLUME_SIZE_GB} \
    --master-zones=${KOPS_MASTER_ZONES} \
    --networking=calico \
    --node-count=${KOPS_NODE_COUNT} \
    --node-size=${KOPS_NODE_SIZE} \
    --node-volume-size=${KOPS_NODE_VOLUME_SIZE_GB} \
    --ssh-access=${KOPS_SSH_IP} \
    --ssh-public-key=${KOPS_PUBLIC_KEY} \
    --target=terraform \
    --vpc=${KOPS_VPC_ID} \
    --zones=${KOPS_ZONES}
```

### Create the cluster

```
source /path/to/config.sh
./install.sh
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


### Additional cluster config

To create the cluster autoscaler policy, Deis S3 buckets, and NodePort access security group, take what you need from this [work in progress script](https://github.com/mozmeao/ee-infra-private/blob/master/k8s/clusters/oregon-b/install2.sh
). 

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

### Calico

#### Install Calico RBAC

```
# Install RBAC as per their docs
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/rbac.yaml
```

#### Block access to AWS Metadata API

```
kubectl create -f etc/networkpolicies/block-metadata.yaml
```

### Verify cluster

- Verify cluster with [Heptio Sonobuoy](https://scanner.heptio.com/)
  - include RBAC in generated Sonobuoy config
  - this process takes ~1 hour to complete.

### Disable public SSH

While ssh access is limited via `kops create cluster`, you can disable ssh access to the cluster altogether with the following command:

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
3. run: `$KOPS_INSTALLER/stage2.sh` ***or*** source and then run each desired function in `$KOPS_INSTALLER/stage2_functions.sh`

Note: each DaemonSet is installed into it's own namespace: `mig`, `datadog`, `newrelic`, and `deis`.

---
# Post install

- [ ] configure Deis
- [ ] store creds
- [ ] store kubeconfig and deis profile
- [ ] update Jenkins
- [ ] request app certs for new region
- [ ] run setup.sh for each application to create nodeports / Deis apps
- [ ] create ELB's (nodeports and certs must be ready)
- [ ] run scale.sh for each application. This can be slow and should be done
once the app seems to be working.

### Setup a Deis Workflow user

Follow the docs [here](https://deis.com/docs/workflow/quickstart/deploy-an-app/) to setup an initial admin user.

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


