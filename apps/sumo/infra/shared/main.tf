provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "sumo-shared-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}

####

resource "aws_s3_bucket" "logs" {
  bucket = "sumo-user-media-logs"
  acl    = "log-delivery-write"
}

module "sumo-user-media-stage-bucket" {
    bucket_name = "sumo-user-media-stage"
    iam_policy_name = "SUMOUserMediaStage"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "stage-logs/"
    region = "${var.region}"
    source = "./s3"
}

module "sumo-user-media-prod-bucket" {
    bucket_name = "sumo-user-media-[rpd]"
    iam_policy_name = "SUMOUserMediaProd"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "prod-logs/"
    region = "${var.region}"
    source = "./s3"
}

module "sumo-user-media-stage-cf" {
    source = "./cloudfront"

    acm_cert_arn = "TODO"
    aliases = ["stage-cdn.sumo.mozilla.net", "stage-cdn.sumo.moz.works"]
    comment = "Stage CDN for SUMO user media"
    distribution_name = "SUMOMediaStageCDN"
    domain_name = "sumo-user-media-stage.s3-website-us-west-2.amazonaws.com"
}

module "sumo-user-media-prod-cf" {
    source = "./cloudfront"

    acm_cert_arn = "TODO"
    aliases = ["prod-cdn.sumo.mozilla.net", "prod-cdn.sumo.moz.works"]
    comment = "Prod CDN for SUMO user media"
    distribution_name = "SUMOMediaProdCDN"
    domain_name = "sumo-user-media-prod.s3-website-us-west-2.amazonaws.com"
}
