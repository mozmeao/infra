provider "aws" {
  region = "${var.region}"
}

########################################
# Primary CDN
########################################

module "primary-cloudfront" {
  source            = "./cloudfront_primary"
  enabled           = "${var.enabled * var.cloudfront_primary_enabled}"
  distribution_name = "${var.cloudfront_primary_distribution_name}-${var.environment}"
  comment           = "Primary ${var.environment} CDN for AWS-hosted MDN"
  acm_cert_arn      = "${var.acm_primary_cert_arn}"
  aliases           = [ "${var.cloudfront_primary_aliases}" ]
  domain_name       = "${var.cloudfront_primary_domain_name}"
}

#module "mdn-primary-cloudfront-stage" {
#    source = "./cloudfront_primary"
#    # *.allizom.org
#    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/bb01357f-b5b5-4e0b-91bb-ccf16c2a49ab"
#    aliases = ["developer.allizom.org"]
#    comment = "Primary Stage CDN for AWS-hosted MDN"
#    distribution_name = "MDNPrimaryStageCDN"
#    domain_name = "stage.mdn.moz.works"
#}

#module "mdn-primary-cloudfront-prod" {
#   source = "./cloudfront_primary"
#   acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/144c40ad-1a60-4865-a252-58ff23961787"
#   aliases = ["developer.mozilla.org"]
#   comment = "Primary Prod CDN for AWS-hosted MDN"
#   distribution_name = "MDNPrimaryProdCDN"
#   domain_name = "prod.mdn.moz.works"
#}

########################################
# Attachments origin
########################################

module "cloudfront-attachments" {
  source            = "./cloudfront_attachments"
  enabled           = "${var.enabled * var.cloudfront_attachments_enabled}"
  distribution_name = "${var.cloudfront_attachments_distribution_name}-${var.environment}"
  comment           = "${var.environment} CDN for AWS-hosted MDN attachments"
  acm_cert_arn      = "${var.acm_attachments_cert_arn}"
  aliases           = [ "${var.cloudfront_attachments_aliases}" ]
  domain_name       = "${var.cloudfront_attachments_domain_name}"
}

#module "mdn-cloudfront-attachments-prod" {
#    source = "./cloudfront_attachments"
#
#    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/4322464c-b6d9-44d9-914d-3554461bcbb3"
#    aliases = ["mdn.mozillademos.org", "mdn-demos.moz.works"]
#    comment = "Prod CDN for AWS-hosted MDN Attachments"
#    distribution_name = "MDNProdAttachmentsCDN"
#    domain_name = "mdn-demos-origin.moz.works"
#}
