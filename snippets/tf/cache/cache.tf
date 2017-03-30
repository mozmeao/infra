variable "region" {}

variable "region_short" {}

variable "cache_node_size" {}

variable "cache_port" {}

variable "cache_num_nodes" {}

variable "cache_param_group" {}

variable "cache_engine_version" {}

variable "cache_subnet_ids" {}

resource "aws_elasticache_subnet_group" "shared-redis-subnet-group" {
  name       = "shared-redis-subnet-group"
  subnet_ids = ["${split(",",var.cache_subnet_ids)}"]
}

resource "aws_elasticache_replication_group" "shared-redis-rg" {
  replication_group_id          = "shared-redis"
  replication_group_description = "Shared redis cluster"
  node_type                     = "${var.cache_node_size}"
  number_cache_clusters         = "${var.cache_num_nodes}"
  port                          = "${var.cache_port}"
  parameter_group_name          = "${var.cache_param_group}"
  engine_version                = "${var.cache_engine_version}"
  subnet_group_name             = "${aws_elasticache_subnet_group.shared-redis-subnet-group.name}"
}
