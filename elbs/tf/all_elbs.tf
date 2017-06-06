provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "elb-provisioning-tf-state"
    # we store all the ELB state in us-west-2
    key = "tf-state"
    region = "us-west-2"
  }
}


# NodePort Security Group
# shared between all ELB's
resource "aws_security_group" "elb_to_nodeport" {
  name        = "elb_to_nodeport"
  description = "Allow all inbound traffic to reach K8s nodeports"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "icmp"

    # https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml#icmp-parameters-codes-3
    # ICMP Destination Unreachable
    from_port = 3

    # Fragmentation Needed and Don't Fragment was Set
    to_port     = 4
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### ELBS

module "snippets" {
  source                       = "./elbs"
  elb_name                     = "${var.snippets_elb_name}"
  subnets                      = "${var.snippets_subnets}"
  http_listener_instance_port  = "${var.snippets_http_listener_instance_port}"
  https_listener_instance_port = "${var.snippets_https_listener_instance_port}"
  ssl_cert_id                  = "${var.snippets_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
}

module "snippets-stats" {
  source                       = "./elbs"
  elb_name                     = "${var.snippets-stats_elb_name}"
  subnets                      = "${var.snippets-stats_subnets}"
  http_listener_instance_port  = "${var.snippets-stats_http_listener_instance_port}"
  https_listener_instance_port = "${var.snippets-stats_https_listener_instance_port}"
  ssl_cert_id                  = "${var.snippets-stats_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
}

module "careers" {
  source                       = "./elbs"
  elb_name                     = "${var.careers_elb_name}"
  subnets                      = "${var.careers_subnets}"
  http_listener_instance_port  = "${var.careers_http_listener_instance_port}"
  https_listener_instance_port = "${var.careers_https_listener_instance_port}"
  ssl_cert_id                  = "${var.careers_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
}

module "bedrock-stage" {
  source                       = "./elbs"
  elb_name                     = "${var.bedrock-stage_elb_name}"
  subnets                      = "${var.bedrock-stage_subnets}"
  http_listener_instance_port  = "${var.bedrock-stage_http_listener_instance_port}"
  https_listener_instance_port = "${var.bedrock-stage_https_listener_instance_port}"
  ssl_cert_id                  = "${var.bedrock-stage_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
  health_check_http_path       = "/healthz/"
}

module "bedrock-prod" {
  source                       = "./elbs"
  elb_name                     = "${var.bedrock-prod_elb_name}"
  subnets                      = "${var.bedrock-prod_subnets}"
  http_listener_instance_port  = "${var.bedrock-prod_http_listener_instance_port}"
  https_listener_instance_port = "${var.bedrock-prod_https_listener_instance_port}"
  ssl_cert_id                  = "${var.bedrock-prod_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
  health_check_http_path       = "/healthz/"
}

module "wilcard-allizom" {
  source                       = "./elbs"
  elb_name                     = "${var.wildcard-allizom_elb_name}"
  subnets                      = "${var.wildcard-allizom_subnets}"
  http_listener_instance_port  = "${var.wildcard-allizom_http_listener_instance_port}"
  https_listener_instance_port = "${var.wildcard-allizom_https_listener_instance_port}"
  ssl_cert_id                  = "${var.wildcard-allizom_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
  health_check_target_proto    = "TCP"
  # leave path empty!
  health_check_http_path      = ""
}

module "nucleus-prod" {
  # if the nucleus-elbs-by-region map contains the current region, then
  # set elb_count to 1, otherwise, default to 0.
  # A value of 1 will create an ELB, a value of 0 won't.
  # NOTE: we still need to pass in dummy values for the variables below
  # when we aren't creating an ELB to allow TF to run
  elb_count = "${lookup(var.nucleus-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.nucleus-prod_elb_name}"
  subnets                      = "${var.nucleus-prod_subnets}"
  http_listener_instance_port  = "${var.nucleus-prod_http_listener_instance_port}"
  https_listener_instance_port = "${var.nucleus-prod_https_listener_instance_port}"
  ssl_cert_id                  = "${var.nucleus-prod_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
  health_check_http_path       = "/"
}

module "surveillance" {
  elb_count = "${lookup(var.surveillance-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.surveillance-prod_elb_name}"
  subnets                      = "${var.surveillance-prod_subnets}"
  http_listener_instance_port  = "${var.surveillance-prod_http_listener_instance_port}"
  https_listener_instance_port = "${var.surveillance-prod_https_listener_instance_port}"
  ssl_cert_id                  = "${var.surveillance-prod_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
  health_check_http_path       = "/"
}

module "basket-stage" {
  source                       = "./elbs"
  elb_name                     = "${var.basket-stage_elb_name}"
  subnets                      = "${var.basket-stage_subnets}"
  http_listener_instance_port  = "${var.basket-stage_http_listener_instance_port}"
  https_listener_instance_port = "${var.basket-stage_https_listener_instance_port}"
  ssl_cert_id                  = "${var.basket-stage_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
  health_check_http_path       = "/healthz/"
}

module "basket-prod" {
  source                       = "./elbs"
  elb_name                     = "${var.basket-prod_elb_name}"
  subnets                      = "${var.basket-prod_subnets}"
  http_listener_instance_port  = "${var.basket-prod_http_listener_instance_port}"
  https_listener_instance_port = "${var.basket-prod_https_listener_instance_port}"
  ssl_cert_id                  = "${var.basket-prod_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
  health_check_http_path       = "/healthz/"
}
