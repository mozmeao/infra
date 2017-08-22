provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mdn-cdn-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}


module "mdn-cloudfront-stage" {
    source = "./cloudfront"

    acm_cert_arn = ""
    aliases = ["stage-cdn.mdn.mozilla.net", "stage-cdn.mdn.moz.works"]
    comment = "Stage CDN for AWS-hosted MDN"
    distribution_name = "MDNStageCDN"
    domain_name = "developer.allizom.org"
}


module "mdn-cloudfront-prod" {
    source = "./cloudfront"

    acm_cert_arn = ""
    aliases = ["cdn.mdn.mozilla.net", "cdn.mdn.moz.works"]
    comment = "Prod CDN for AWS-hosted MDN"
    distribution_name = "MDNProdCDN"
    domain_name = "developer.mozilla.org"
}





