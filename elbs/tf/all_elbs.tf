provider "aws" {
  region = "${var.region}"
}

# NodePort Security Group
# shared between all ELB's
resource "aws_security_group" "elb_to_nodeport" {
  name        = "elb_to_nodeport"
  description = "Allow all inbound traffic to reach K8s nodeports"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "nodeport_ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 30000
  to_port           = 32767
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_to_nodeport.id}"
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_to_nodeport.id}"
}

resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_to_nodeport.id}"
}

resource "aws_security_group_rule" "custom_icmp" {
  type     = "ingress"
  protocol = "icmp"

  # https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml#icmp-parameters-codes-3
  # ICMP Destination Unreachable
  from_port = 3

  # Fragmentation Needed and Don't Fragment was Set
  to_port           = 4
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_to_nodeport.id}"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_to_nodeport.id}"
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

module "careers" {
  source                       = "./elbs"
  elb_name                     = "${var.careers_elb_name}"
  subnets                      = "${var.careers_subnets}"
  http_listener_instance_port  = "${var.careers_http_listener_instance_port}"
  https_listener_instance_port = "${var.careers_https_listener_instance_port}"
  ssl_cert_id                  = "${var.careers_ssl_cert_id}"
  security_group_id            = "${aws_security_group.elb_to_nodeport.id}"
}
