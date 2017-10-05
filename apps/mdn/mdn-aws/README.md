# MDN AWS provisioning

## Requirements:

- Terraform
- Access to the IAM role `admin` role via the AWS metadata API
- awscli

## Usage


#### shared resources (S3 buckets, etc):

```sh
cd ./infra/shared/
./provision.sh
```

#### Provisioning region-specific resources:

```sh
cd ./infra/multi_region/portland
./provision.sh
```
