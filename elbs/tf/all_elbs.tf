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

### ELBS

module "snippets" {
  elb_count = "${lookup(var.snippets-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.snippets_elb_name}"
  subnets                      = "${var.snippets_subnets}"
  http_listener_instance_port  = "${var.snippets_http_listener_instance_port}"
  https_listener_instance_port = "${var.snippets_https_listener_instance_port}"
  ssl_cert_id                  = "${var.snippets_ssl_cert_id}"
  security_group_id            = "${var.elb_access_id}"
  health_check_http_path       = "/healthz/"
}

module "snippets-stats" {
  elb_count = "${lookup(var.snippets-stats-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.snippets-stats_elb_name}"
  subnets                      = "${var.snippets-stats_subnets}"
  http_listener_instance_port  = "${var.snippets-stats_http_listener_instance_port}"
  https_listener_instance_port = "${var.snippets-stats_https_listener_instance_port}"
  ssl_cert_id                  = "${var.snippets-stats_ssl_cert_id}"
  security_group_id            = "${var.elb_access_id}"
}

module "careers" {
  elb_count = "${lookup(var.careers-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.careers_elb_name}"
  subnets                      = "${var.careers_subnets}"
  http_listener_instance_port  = "${var.careers_http_listener_instance_port}"
  https_listener_instance_port = "${var.careers_https_listener_instance_port}"
  ssl_cert_id                  = "${var.careers_ssl_cert_id}"
  security_group_id            = "${var.elb_access_id}"
  health_check_http_path       = "/healthz/"
}

module "bedrock-stage" {
  elb_count = "${lookup(var.bedrock-stage-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.bedrock-stage_elb_name}"
  subnets                      = "${var.bedrock-stage_subnets}"
  http_listener_instance_port  = "${var.bedrock-stage_http_listener_instance_port}"
  https_listener_instance_port = "${var.bedrock-stage_https_listener_instance_port}"
  ssl_cert_id                  = "${var.bedrock-stage_ssl_cert_id}"
  security_group_id            = "${var.elb_access_id}"
  health_check_http_path       = "/healthz/"
}

module "bedrock-prod" {
  elb_count = "${lookup(var.bedrock-prod-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.bedrock-prod_elb_name}"
  subnets                      = "${var.bedrock-prod_subnets}"
  http_listener_instance_port  = "${var.bedrock-prod_http_listener_instance_port}"
  https_listener_instance_port = "${var.bedrock-prod_https_listener_instance_port}"
  ssl_cert_id                  = "${var.bedrock-prod_ssl_cert_id}"
  security_group_id            = "${var.elb_access_id}"
  health_check_http_path       = "/healthz/"
}

module "wilcard-allizom" {
  elb_count = "${lookup(var.wildcard-allizom-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.wildcard-allizom_elb_name}"
  subnets                      = "${var.wildcard-allizom_subnets}"
  http_listener_instance_port  = "${var.wildcard-allizom_http_listener_instance_port}"
  https_listener_instance_port = "${var.wildcard-allizom_https_listener_instance_port}"
  ssl_cert_id                  = "${var.wildcard-allizom_ssl_cert_id}"
  security_group_id            = "${var.elb_access_id}"
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
  security_group_id            = "${var.elb_access_id}"
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
  security_group_id            = "${var.elb_access_id}"
  health_check_http_path       = "/"
}

module "basket-stage" {
  elb_count = "${lookup(var.basket-stage-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.basket-stage_elb_name}"
  subnets                      = "${var.basket-stage_subnets}"
  http_listener_instance_port  = "${var.basket-stage_http_listener_instance_port}"
  https_listener_instance_port = "${var.basket-stage_https_listener_instance_port}"
  ssl_cert_id                  = "${var.basket-stage_ssl_cert_id}"
  security_group_id            = "${var.elb_access_id}"
  health_check_http_path       = "/healthz/"
}

module "basket-prod" {
  elb_count = "${lookup(var.basket-prod-elbs-by-region, var.region, 0)}"
  source                       = "./elbs"
  elb_name                     = "${var.basket-prod_elb_name}"
  subnets                      = "${var.basket-prod_subnets}"
  http_listener_instance_port  = "${var.basket-prod_http_listener_instance_port}"
  https_listener_instance_port = "${var.basket-prod_https_listener_instance_port}"
  ssl_cert_id                  = "${var.basket-prod_ssl_cert_id}"
  security_group_id            = "${var.elb_access_id}"
  health_check_http_path       = "/healthz/"
}
