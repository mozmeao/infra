# MDN AWS provisioning

### How to apply config to a single cluster


shared resources (S3 buckets, etc):

```shell
cd ./shared/
./provision.sh
```

Provisioning region-specific resources:

```shell
cd ./multi_region/virginia
./provision.sh
```
