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


module "snippets-cdn-stage" {
  source      = "./stage_cdn"
  environment = "stage"

  # Commented out because snippets.cdn.mozilla.net is used, uncomment
  # once everything is fully tested
  #aliases = [ "snippets-prod-cdn.moz.works", "snippets.cdn.mozilla.net"]
  aliases = ["snippets-stage-cdn.moz.works"]

  comment    = "Used by Firefox (stage)"
  log_bucket = "${aws_s3_bucket.snippets-logging.bucket_domain_name}"
  log_prefix = "snippets-stage/"

  certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/3a7ae4ad-3b7b-449a-a5ea-0238295dc6fd"
  origin_domain_name = "snippets-stage-us-west.s3.amazonaws.com"
  default_cache_target_origin_id = "snippets.allizom.org"
  ordered_cache_target_origin_id = "S3-snippets-stage-us-west"
}


module "snippets-cdn-prod" {
  source      = "./prod_cdn"
  environment = "prod"

  aliases = [ "snippets-prod-cdn.moz.works", "snippets.cdn.mozilla.net"]

  comment    = "Used by Firefox (prod)"
  log_bucket = "${aws_s3_bucket.snippets-logging.bucket_domain_name}"
  log_prefix = "snippets-prod/"

  certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/5f2b4283-3fbc-4edc-bed7-9018c065d918"
  origin_domain_name = "snippets-prod-us-west.s3.amazonaws.com"
  default_cache_target_origin_id = "snippets.mozilla.com"
  ordered_cache_target_origin_id = "S3-snippets-prod-us-west"
}
