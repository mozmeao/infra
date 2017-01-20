# MozMeao Kubernetes install

### Prereqs

- kops
- terraform
- [helm](https://github.com/kubernetes/helm/blob/master/docs/install.md)
- awscli


### Building a new kops cluster

```
# modify stage1.sh to your liking
cd ee-infra-private/k8s/install
export KOPS_INSTALLER=$(pwd)

mkdir my_cluster
cd my_cluster
cp $KOPS_INSTALLER/etc/config.sh.template config.sh
```

**At this point, you MUST customize config.sh.**

When you're ready, run the installer:
```
source config.sh
$KOPS_INSTALLER/stage1.sh
```

Two different sets of results of `stage1.sh` are stored in:
 - a) `./out/terraform` (terraform only)
 - b) general kops config stored in an S3 bucket: `$KOPS_STATE_STORE`.

When you're ready to continue, apply the Terraform config:

```
cd out/terraform
terraform plan
terraform apply
```

Wait ~10 minutes.

Check your cluster with:

```
# ensure you're pointing at the correct kops cluster first!
kubectl config current-context
kubectl get nodes
```

### Installing monitoring services

This step installs Mig, Datadog, New Relic DaemonSets, and the k8s dashboard.
You must unlock the repo before running this script.

```
$KOPS_INSTALLER/stage2.sh
```

Note: each DaemonSet is installed into it's own namespace: `mig`, `datadog`, and `newrelic`.

---
# Post install

### Accessing the bastion

See [https://github.com/kubernetes/kops/blob/master/docs/bastion.md#using-ssh-agent-to-access-your-bastion](this page) for more info.


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
