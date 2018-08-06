terraform {
  backend "s3" {
    bucket = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key    = "terraform/dns"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
}

resource aws_route53_delegation_set "delegation-set" {

  lifecycle {
    create_before_destroy = true
  }

  reference_name = "${var.reference_name}"
}

resource aws_route53_zone "master-zone" {
  name = "${var.domain_name}"

  delegation_set_id = "${aws_route53_delegation_set.delegation-set.id}"

  tags {
    Name    = "${var.domain_name}"
    Purpose = "MDN DNS master zone"
  }
}

module "us-west-2" {
  source      = "./hosted_zone"
  region      = "us-west-2"
  domain_name = "${var.domain_name}"
  zone_id     = "${aws_route53_zone.master-zone.id}"
}
