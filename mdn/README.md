# MDN infra

### Requirements:

- Terraform
- Access to the IAM role `admin` role via the AWS metadata API
- awscli


## Usage

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