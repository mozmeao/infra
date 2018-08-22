# Put acm certs thats needed here, just makes the main.tf less insane

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

module "interactive-example-acm" {
  source = "./acm"

  providers = {
    aws = "aws.acm"
  }

  domain_name = "interactive-examples.mdn.mozit.cloud"
  zone_id     = "${data.terraform_remote_state.dns.master-zone}"
}

module "acm_ci" {
  source = "./acm"

  domain_name = "ci.us-west-2.mdn.mozit.cloud"
  zone_id     = "${data.terraform_remote_state.dns.us-west-2-zone-id}"
}
