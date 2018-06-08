variable "enabled" {}

variable "region" {}

variable "environment" {}

variable "account" {}

variable "enable_memcached" {}

variable "enable_rds" {}

variable "enable_efs" {}

variable "enable_redis" {}

variable "memcached_node_size" {
  default = "cache.t2.small"
}

variable "memcached_num_nodes" {
  default = "3"
}

variable "redis_node_size" {
  default = "cache.t2.small"
}

variable "redis_num_nodes" {
  default = "3"
}

variable "mysql_db_name" {}

variable "mysql_username" {
  default = "root"
}

variable "mysql_password" {}

variable "mysql_instance_class" {}

variable "mysql_backup_retention_days" {}

variable "mysql_security_group_name" {
  default = "mds_rds_sg"
}

variable "mysql_storage_gb" {
  default = "100"
}

variable "mysql_storage_type" {
  default = "gp2"
}

variable "kube_cluster_name" {
  default = "kubernetes"
}
