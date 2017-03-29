provider "aws" {
  region = "${var.region}"
}

##### Buckets

module "bucket-stage" {
  source       = "../tf/storage"
  environment  = "stage"
  region       = "${var.region}"
  region_short = "${var.region_short}"
}

module "bucket-prod" {
  source       = "../tf/storage"
  environment  = "prod"
  region       = "${var.region}"
  region_short = "${var.region_short}"
}

module "prod-alerts" {
  source = "../tf/alerting"
  region = "${var.region}"
  fqdn   = "${var.fqdn_prod}"
  name   = "${var.alarm_name_prod}"
}

# do we want stage alerts?
module "stage-alerts" {
  source = "../tf/alerting"
  region = "${var.region}"
  fqdn   = "${var.fqdn_stage}"
  name   = "${var.alarm_name_stage}"
}

module "redis" {
  source            = "../tf/cache"
  region            = "${var.region}"
  region_short      = "${var.region_short}"
  cache_node_size   = "${var.cache_node_size}"
  cache_port        = "${var.cache_port}"
  cache_num_nodes   = "${var.cache_num_nodes}"
  cache_param_group = "${var.cache_param_group}"
}
