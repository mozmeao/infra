variable "region" {}

variable "region_short" {}

variable "cache_node_size" {}

variable "cache_port" {}

variable "cache_num_nodes" {}

variable "cache_param_group" {}

resource "aws_elasticache_cluster" "shared-redis" {
  cluster_id           = "redis-shared-${var.region_short}"
  engine               = "redis"
  node_type            = "${var.cache_node_size}"
  port                 = "${var.cache_port}"
  num_cache_nodes      = "${var.cache_num_nodes}"
  parameter_group_name = "${var.cache_param_group}"
}
