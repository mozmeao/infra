provider "aws" {
  region  = "${var.region}"
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
