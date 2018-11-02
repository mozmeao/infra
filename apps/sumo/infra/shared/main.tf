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


#####################################################################
# S3 buckets for user media
#####################################################################
resource "aws_s3_bucket" "logs" {
  bucket = "sumo-user-media-logs"
  acl    = "log-delivery-write"
}

module "sumo-user-media-dev-bucket" {
    bucket_name = "sumo-user-media-dev"
    iam_policy_name = "SUMOUserMediaDev"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "dev-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

module "sumo-user-media-stage-bucket" {
    bucket_name = "sumo-user-media-stage"
    iam_policy_name = "SUMOUserMediaStage"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "stage-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

module "sumo-user-media-prod-bucket" {
    bucket_name = "sumo-user-media-prod"
    iam_policy_name = "SUMOUserMediaProd"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "prod-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

#####################################################################
# S3 buckets for static media
#####################################################################

resource "aws_s3_bucket" "static-media-logs" {
  bucket = "sumo-static-media-logs"
  acl    = "log-delivery-write"
}

module "sumo-static-media-stage-bucket" {
    bucket_name = "sumo-stage-media"
    iam_policy_name = "SUMOStaticMediaStage"
    logging_bucket_id = "${aws_s3_bucket.static-media-logs.id}"
    logging_prefix = "stage-logs/"
    region = "${var.region}"
    source = "./static_media_s3"
}

module "sumo-static-media-prod-bucket" {
    bucket_name = "sumo-prod-media"
    iam_policy_name = "SUMOStaticMediaProd"
    logging_bucket_id = "${aws_s3_bucket.static-media-logs.id}"
    logging_prefix = "prod-logs/"
    region = "${var.region}"
    source = "./static_media_s3"
}

#####################################################################
# user media CDN
#####################################################################
module "sumo-user-media-dev-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/86ae4eda-a6eb-4186-bbce-0cbcc3fe0a7c"
    aliases = ["dev-cdn.sumo.mozilla.net", "dev-cdn.sumo.moz.works"]
    comment = "Dev CDN for SUMO user media"
    distribution_name = "SUMOMediaDevCDN"
    domain_name = "sumo-user-media-dev.s3-website-us-west-2.amazonaws.com"
}

module "sumo-user-media-stage-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/28ed8c22-1c79-4a21-bf9e-2882f1f221fa"
    aliases = ["stage-cdn.sumo.mozilla.net", "stage-cdn.sumo.moz.works"]
    comment = "Stage CDN for SUMO user media"
    distribution_name = "SUMOMediaStageCDN"
    domain_name = "sumo-user-media-stage.s3-website-us-west-2.amazonaws.com"
}

module "sumo-user-media-prod-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/5e20025f-600c-4ad8-a7c1-78bbc705988e"
    aliases = ["prod-cdn.sumo.mozilla.net", "prod-cdn.sumo.moz.works"]
    comment = "Prod CDN for SUMO user media"
    distribution_name = "SUMOMediaProdCDN"
    domain_name = "sumo-user-media-prod.s3-website-us-west-2.amazonaws.com"
}

#####################################################################
# static media CDN
#####################################################################
module "sumo-static-media-dev-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/5107c225-e7ce-44d5-9053-22179a77773a"
    aliases = ["static-media-dev-cdn.sumo.mozilla.net", "static-media-dev-cdn.sumo.moz.works"]
    comment = "Dev CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaDevCDN"
    domain_name = "dev.sumo.moz.works"
}

module "sumo-static-media-stage-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/404af773-625d-43e2-95f8-6a34c58543d5"
    aliases = ["static-media-stage-cdn.sumo.mozilla.net", "static-media-stage-cdn.sumo.moz.works"]
    comment = "Stage CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaStageCDN"
    domain_name = "stage-tp.sumo.moz.works"
}

module "sumo-static-media-prod-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/b60b88ee-a86d-4f1a-a848-62dd821b9de7"
    aliases = ["static-media-prod-cdn.sumo.mozilla.net", "static-media-prod-cdn.sumo.moz.works"]
    comment = "Prod CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaProdCDN"
    domain_name = "support.mozilla.org"
}

#####################################################################
# failover CDN
#####################################################################
module "sumo-failover-cf" {
    source = "./cloudfront_failover"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/be925ea5-c206-4831-8468-1e939245b614"
    aliases = ["support.mozilla.org", "support.mozilla.com", "failover-cdn.sumo.moz.works"]
    comment = "Frankfurt failover CDN"
    distribution_name = "SUMOFailoverCDN"
    domain_name = "prod-frankfurt.sumo.moz.works"
    min_ttl = 0
    max_ttl = 28800     /* 8 hours */
    default_ttl = 14400 /* 4 hours */
}
