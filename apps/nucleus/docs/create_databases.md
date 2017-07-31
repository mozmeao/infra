# Nucleus Postgres setup

For each RDS instance, you'll need to connect to Postgres via K8s:

```
# if you don't have your own K8s namespace, you can easily create one with:
kubectl create namespace your_namespace
# replacing your_namespace with whatever you like

# next, start a postgres pod to use the psql client:
kubectl -n your_namespace run -i -t pgsql --image=postgres -- bash
psql -h some_url -U bedrock
```

Once you've connected to Postgres, run the following script with `[REDACTED]` replaced with appropriate passwords:

```
create role nucleus_dev;
create role nucleus_prod;

create database nucleus_dev;
create database nucleus_prod;

alter database nucleus_dev owner to nucleus_dev ;
alter database nucleus_prod owner to nucleus_prod;

alter role nucleus_dev with password '[REDACTED]';
alter role nucleus_prod with password '[REDACTED]';

alter role nucleus_dev login;
alter role nucleus_prod login;
```

Cleanup when you're finished:

```
kubectl -n your_namespace delete deployment pgsql
```
