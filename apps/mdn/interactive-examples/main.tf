provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key    = "terraform/interactive-example"
    region = "us-west-2"
  }
}

provider "aws" {
  alias  = "aws-acm"
  region = "us-east-1"
}

data "aws_acm_certificate" "interactive-example" {
  provider = "aws.aws-acm"
  domain   = "interactive-examples.mdn.mozit.cloud"
  statuses = ["ISSUED"]
}

module "interactive-example" {
  source = "./tf"
  acm_certificate_arn = "${data.aws_acm_certificate.interactive-example.arn}"
}
