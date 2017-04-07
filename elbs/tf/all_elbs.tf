provider "aws" {
  region = "${var.region}"
}

module "snippets" {
  source                       = "./elbs"
  elb_name                     = "${var.snippets_elb_name}"
  subnets                      = "${var.snippets_subnets}"
  instances                    = "${var.snippets_instances}"
  http_listener_instance_port  = "${var.snippets_http_listener_instance_port}"
  https_listener_instance_port = "${var.snippets_https_listener_instance_port}"
  ssl_cert_id                  = "${var.snippets_ssl_cert_id}"
}

module "careers" {
  source                       = "./elbs"
  elb_name                     = "${var.careers_elb_name}"
  subnets                      = "${var.careers_subnets}"
  instances                    = "${var.careers_instances}"
  http_listener_instance_port  = "${var.careers_http_listener_instance_port}"
  https_listener_instance_port = "${var.careers_https_listener_instance_port}"
  ssl_cert_id                  = "${var.careers_ssl_cert_id}"
}
