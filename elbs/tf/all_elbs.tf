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


