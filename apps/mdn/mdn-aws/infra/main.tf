provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key    = "terraform/mdn-infra"
    region = "us-west-2"
  }
}

module "mdn_shared" {
  source  = "./shared"
  enabled = "${lookup(var.features, "shared-infra")}"
  region  = "${var.region}"
}

# ACM certs for cloudfront needs to be created in us-east-1
# as documented here: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html
provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}

module "acm_star_mdn" {
  source = "./acm"

  providers = {
    aws = "aws.acm"
  }

  domain_name = "*.mdn.mozit.cloud"
  zone_id     = "${data.terraform_remote_state.dns.master-zone}"
}

module "mdn_cdn" {
  source      = "./mdn-cdn"
  enabled     = "${lookup(var.features, "cdn")}"
  region      = "${var.region}"
  environment = "${var.environment}"

  # Primary CDN
  cloudfront_primary_enabled           = "${lookup(var.cloudfront_primary, "enabled")}"
  acm_primary_cert_arn                 = "${module.acm_star_mdn.certificate_arn}"
  cloudfront_primary_distribution_name = "${lookup(var.cloudfront_primary, "distribution_name")}"
  cloudfront_primary_aliases           = "${split(",", lookup(var.cloudfront_primary, "aliases.${var.environment}"))}"
  cloudfront_primary_domain_name       = "${lookup(var.cloudfront_primary, "domain.${var.environment}")}"

  # attachment CDN
  cloudfront_attachments_enabled           = "${(lookup(var.cloudfront_attachments, "enabled")) * (var.environment == "stage" ? 0 : 1)}"
  acm_attachments_cert_arn                 = "${module.acm_star_mdn.certificate_arn}"
  cloudfront_attachments_distribution_name = "${lookup(var.cloudfront_attachments, "distribution_name")}"
  cloudfront_attachments_aliases           = "${split(",", lookup(var.cloudfront_attachments, "aliases.${var.environment}"))}"
  cloudfront_attachments_domain_name       = "${lookup(var.cloudfront_attachments, "domain.${var.environment}")}"
}

# Multi region resources

