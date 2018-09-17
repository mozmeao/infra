# Put acm certs thats needed here, just makes the main.tf less insane

# ACM certs for cloudfront needs to be created in us-east-1
# as documented here: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html
provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}

module "acm_star_mdn" {
  source = "./modules/acm"

  providers = {
    aws = "aws.acm"
  }

  domain_name = "*.mdn.mozit.cloud"
  zone_id     = "${data.terraform_remote_state.dns.master-zone}"
}

module "interactive-example-acm" {
  source = "./modules/acm"

  providers = {
    aws = "aws.acm"
  }

  domain_name = "interactive-examples.mdn.mozit.cloud"
  zone_id     = "${data.terraform_remote_state.dns.master-zone}"
}

module "acm_ci" {
  source = "./modules/acm"

  domain_name = "ci.us-west-2.mdn.mozit.cloud"
  zone_id     = "${data.terraform_remote_state.dns.us-west-2-zone-id}"
}

data aws_acm_certificate "prod-primary-cdn-cert" {
  provider = "aws.acm"
  domain   = "developer.mozilla.org"
  statuses = ["ISSUED"]
}

data aws_acm_certificate "stage-primary-cdn-cert" {
  provider = "aws.acm"
  domain   = "developer.allizom.org"
  statuses = ["ISSUED"]

}
data aws_acm_certificate "attachment-cdn-cert" {
  provider = "aws.acm"
  domain   = "mdn.mozillademos.org"
  statuses = ["ISSUED"]
}
