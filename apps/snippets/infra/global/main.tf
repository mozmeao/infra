provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "snippets-shared-tf-state"
    key    = "snippets-cdn"
    region = "us-west-2"
  }
}

locals {
  log-bucket = "snippets-cdn-logs-${data.aws_caller_identity.current.account_id}"
}

data "aws_caller_identity" current {}

resource "aws_s3_bucket" "snippets-logging" {
  bucket = "${local.log-bucket}"
  region = "${var.region}"
  acl    = "log-delivery-write"

  tags {
    Name      = "${local.log-bucket}"
    Region    = "${var.region}"
    Terraform = "true"
  }
}

module "snippets-cdn-prod" {
  source      = "./cdn"
  environment = "prod"

  # Commented out because snippets.cdn.mozilla.net is used, uncomment
  # once everything is fully tested
  #aliases = [ "snippets-prod-cdn.moz.works", "snippets.cdn.mozilla.net"]
  aliases = ["snippets-prod-cdn.moz.works"]

  comment    = "User by Firefox (prod)"
  log_bucket = "${aws_s3_bucket.snippets-logging.bucket_domain_name}"
  log_prefix = "snippets-prod/"

  certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/8f1a65e7-2d0f-40e7-a74a-8d5056fd2462"
}
