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

########################################
# Primary CDN
########################################
module "mdn-primary-cloudfront-stage" {
    source = "./cloudfront_primary"
    # *.allizom.org
    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/fc2f09d3-8caa-4aff-944a-209758821952"
    aliases = ["developer.allizom.org"]
    comment = "Primary Stage CDN for AWS-hosted MDN"
    distribution_name = "MDNPrimaryStageCDN"
    domain_name = "stage.mdn.moz.works"
}

module "mdn-primary-cloudfront-prod" {
   source = "./cloudfront_primary"
   acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/144c40ad-1a60-4865-a252-58ff23961787"
   aliases = ["developer.mozilla.org"]
   comment = "Primary Prod CDN for AWS-hosted MDN"
   distribution_name = "MDNPrimaryProdCDN"
   domain_name = "prod.mdn.moz.works"
}

########################################
# Attachments origin
########################################
module "mdn-cloudfront-attachments-prod" {
    source = "./cloudfront_attachments"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/4322464c-b6d9-44d9-914d-3554461bcbb3"
    aliases = ["mdn.mozillademos.org", "mdn-demos.moz.works"]
    comment = "Prod CDN for AWS-hosted MDN Attachments"
    distribution_name = "MDNProdAttachmentsCDN"
    domain_name = "mdn-demos-origin.moz.works"
}
