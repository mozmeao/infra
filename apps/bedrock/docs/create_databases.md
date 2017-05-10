# Bedrock Postgres setup

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
create role bedrock_dev;
create role bedrock_stage;
create role bedrock_prod;

create database bedrock_dev;
create database bedrock_stage;
create database bedrock_prod;

alter database bedrock_dev owner to bedrock_dev ;
alter database bedrock_stage owner to bedrock_stage;
alter database bedrock_prod owner to bedrock_prod;

alter role bedrock_dev with password '[REDACTED]';
alter role bedrock_stage with password '[REDACTED]';
alter role bedrock_prod with password '[REDACTED]';

alter role bedrock_dev login;
alter role bedrock_stage login;
alter role bedrock_prod login;
```

Cleanup when you're finished:

```
kubectl -n your_namespace delete deployment pgsql
```