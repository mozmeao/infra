# MDN infra

### Requirements:

- Terraform
- Access to the IAM role `admin` role via the AWS metadata API
- awscli

## Usage

- This command and all following assume the same directory as this file unless otherwise specified

```
./provision.sh
```

This will setup the S3 Terraform state store if needed, and then run `terraform plan` followed by `terraform apply`.

---

NOTE:

As the `mdn-downloads` bucket already exists and was created outside of Terraform, it was imported with the following command:


```
terraform import aws_s3_bucket.mdn-downloads mdn-downloads
```

This resource is stored in the Terraform S3 state, so the command doesn't need to be run again.


## Restoring a database to a persistent MySQL container

- install kubectl and helm, if necessary
  - this is done as part of the [stage2.sh](../k8s/install/stage2.sh) install or you can manually run the following:

```sh
source ../k8s/install/stage2_functions.sh
export HELM_VERSION=2.2.3  # normally set in stage2.sh
install_helm
install_kubectl
kubectl config # or export KUBECONFIG=~/path/to/kubeconfig
kubectl get nodes # or another command to verify successful auth
helm init
```

- clone mdn/helm-charts

```sh
git clone https://github.com/mdn/helm-charts charts # TODO: consolidate charts into this repo
```

- edit charts/mysql/values.yaml

```yaml
persistence:
  enabled: true
  accessMode: ReadWriteOnce
  size: 40Gi

```

- install from the local directory

```sh
cd mdn/charts/mysql
helm install . --namespace mdn-dev
```

- sample output

```
NAME:   yellow-wolverine
LAST DEPLOYED: Fri Mar 31 20:18:23 2017
NAMESPACE: mdn-dev
STATUS: DEPLOYED

RESOURCES:
==> v1/Secret
NAME                    TYPE    DATA  AGE
yellow-wolverine-mysql  Opaque  2     1s

==> v1/PersistentVolumeClaim
NAME                    STATUS   VOLUME  CAPACITY  ACCESSMODES  AGE
yellow-wolverine-mysql  Pending  1s

==> v1/Service
NAME                    CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
yellow-wolverine-mysql  100.69.195.67  <none>       3306/TCP  1s

==> extensions/v1beta1/Deployment
NAME                    DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
yellow-wolverine-mysql  1        1        1           0          1s


NOTES:
MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
yellow-wolverine-mysql.mdn-dev.svc.cluster.local

To get your root password run:

kubectl get secret --namespace mdn-dev yellow-wolverine-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo

To connect to your database:

1. Run an Ubuntu pod that you can use as a client:

kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il

2. Install the mysql client:

$ apt-get update && apt-get install mysql-client -y

3. Connect using the mysql cli, then provide your password:

$ mysql -h yellow-wolverine-mysql -p
```

- instead of opening a separate container as in the example output above, we're going to exec a bash shell in the mysql container directly

```sh
kubectl exec -i -t $(kubectl get pods | grep mysql | awk '{print $1}') bash
```

- install awscli

```sh
export TERM=screen-256color
apt update && apt install -y awscli groff less
```

- config auth and copy data from private s3 bucket

```sh
aws configure # populate access key and secret
export BUCKET=mdn-db-storage-anonymized
aws s3 ls $BUCKET # find filename of latest backup
export BACKUP=developer_mozilla_org-anon-20170301.sql.gz
mkdir /var/lib/mysql/backups
aws s3 cp s3://$BUCKET/$BACKUP /var/lib/mysql/backups/
```

- restore from backup

```sh
#see example output from "helm install ." for how to get generated mysql password
export DATABASE=developer_mozilla_org
mysql -e "create database $DATABASE;" -p
zcat /var/lib/mysql/backups/$BACKUP | mysql -p $DATABASE
```
