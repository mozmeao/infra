# MySQL for MDN Maintenance Mode

The `install_mysql.sh` script in this directory deploys a MySQL instance via [helm chart](https://github.com/kubernetes/charts/tree/master/stable/mysql). 

Since we use [a custom MySQL image](https://quay.io/repository/mozmar/mdn-mysql?tag=latest&tab=tags) with custom collation, we need to modify the MySQL Chart on the fly to use our image instead of the default.

### Prereqs

- Access to the private infra repo
- `kubectl`, pointing at the appropriate K8s cluster
- `helm`

### Usage

```
./install_mysql.sh
```

### Connecting to MySQL

You can start a temporary container to connect to the new MySQL instance:

```
kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il

apt-get update && apt-get install mysql-client wget -y

# you'll need the password from $PATH_TO_MYSQL_SETTINGS
mysql -h mdn-mm-mysql-mysql.mdn-mm.svc.cluster.local -p

# to import the mm db:
wget -N https://mdn-downloads.s3-us-west-2.amazonaws.com/mdn_sample_db.sql.gz
zcat mdn_sample_db.sql.gz | mysql -h mdn-mm-mysql-mysql.mdn-mm.svc.cluster.local -p mdn-mm 


# we can't start another pod named "ubuntu" unless this one is deleted.
# you can see completed pods w/ kubectl get pods --show-all
kubectl delete pod ubuntu
```
