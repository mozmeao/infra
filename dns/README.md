# MDN DNS setup
This repository creates the DNS records needed to setup kubernetes, since the domain is owned by mozilla this will create a delegation set
and we can delegate the domain on the mozilla side of things

## State bucket
We assume the state bucket is created, we create the state bucket by doing the following

```bash
aws s3 mb s3://mdn-state-4e366a3ac64d1b4022c8b5e35efbd288 --region us-west-2
aws s3api put-bucket-versioning --bucket mdn-state-4e366a3ac64d1b4022c8b5e35efbd288 --versioning-configuration Status=Enabled --region us-west-2
```

The hash on the bucket name is to avoid collisions with other buckets in the AWS namespace

```bash
echo "mdn-state-$(date +%s | md5sum | cut -d ' ' -f 1)"
```


## Provisioning

This assumes that you have the relevant AWS credentials setup and exported.

```bash
cd dns
terraform init
terraform plan
terraform apply -input=yes -auto-approve
```

If you need to add another DNS zone for a different region just add the following to `main.tf`


```bash
module "us-east-1" {
  source      = "./hosted_zone"
  region      = "us-east-1"
  domain_name = "${var.domain_name}"
  zone_id     = "${aws_route53_zone.master-zone.id}"
}
```
