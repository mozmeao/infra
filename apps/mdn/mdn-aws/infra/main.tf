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

module "acm_ci" {
  source = "./acm"

  domain_name = "ci.us-west-2.mdn.mozit.cloud"
  zone_id     = "${data.terraform_remote_state.dns.us-west-2-zone-id}"
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

module "efs-us-west-2" {
  source               = "./multi_region/efs"
  enabled              = "${lookup(var.features, "efs")}"
  environment          = "${var.environment}"
  region               = "us-west-2"
  efs_name             = "${var.environment}"
  subnets              = "${join(",", data.terraform_remote_state.kubernetes-us-west-2.node_subnet_ids)}"
  nodes_security_group = "${data.terraform_remote_state.kubernetes-us-west-2.node_security_group_ids}"
}

module "redis-us-west-2" {
  source               = "./multi_region/redis"
  enabled              = "${lookup(var.features, "redis")}"
  environment          = "${var.environment}"
  region               = "us-west-2"
  redis_name           = "${var.environment}"
  redis_node_size      = "${lookup(var.redis, "node_size.${var.environment}")}"
  redis_num_nodes      = "${lookup(var.redis, "num_nodes.${var.environment}")}"
  subnets              = "${join(",", data.terraform_remote_state.kubernetes-us-west-2.node_subnet_ids)}"
  nodes_security_group = "${data.terraform_remote_state.kubernetes-us-west-2.node_security_group_ids}"
}

module "memcached-us-west-2" {
  source               = "./multi_region/memcached"
  enabled              = "${lookup(var.features, "memcached")}"
  environment          = "${var.environment}"
  region               = "us-west-2"
  memcached_name       = "${var.environment}"
  memcached_node_size  = "${lookup(var.memcached, "node_size.${var.environment}")}"
  memcached_num_nodes  = "${lookup(var.memcached, "num_nodes.${var.environment}")}"
  subnets              = "${join(",", data.terraform_remote_state.kubernetes-us-west-2.node_subnet_ids)}"
  nodes_security_group = "${data.terraform_remote_state.kubernetes-us-west-2.node_security_group_ids}"
}

module "mysql-us-west-2" {
  source                      = "./multi_region/rds"
  enabled                     = "${lookup(var.features, "rds")}"
  environment                 = "${var.environment}"
  region                      = "us-west-2"
  mysql_env                   = "${var.environment}"
  mysql_db_name               = "${lookup(var.rds, "db_name.${var.environment}")}"
  mysql_username              = "${lookup(var.rds, "username.${var.environment}")}"
  mysql_password              = "${lookup(var.rds, "password.${var.environment}")}"
  mysql_identifier            = "mdn-${var.environment}"
  mysql_instance_class        = "${lookup(var.rds, "instance_class.${var.environment}")}"
  mysql_backup_retention_days = "${lookup(var.rds, "backup_retention_days.${var.environment}")}"
  mysql_security_group_name   = "mdn_rds_sg_${var.environment}"
  mysql_storage_gb            = "${lookup(var.rds, "storage_gb.${var.environment}")}"
  mysql_storage_type          = "${lookup(var.rds, "storage_type")}"
  vpc_id                      = "${data.terraform_remote_state.kubernetes-us-west-2.vpc_id}"
  vpc_cidr                    = "${data.aws_vpc.cidr.cidr_block}"
  subnets                     = "${join(",", data.aws_subnet_ids.subnet_id.ids)}"
}
