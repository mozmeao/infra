module "us-west-2" {
  source = "./tf"

  region = "us-west-2"

  # Okay, somewhat nasty
  #  - take the list of regions, look for the one we care about and make it XXX
  #  - take the result, and make all non-Xes into Ys
  #  - take the result of that (should be either XXX or YYY...)
  #  - change XXX, if found into 1
  #  - change YYY... if found into 0
  #  Result, 1 if the region is found, 0 otherwise
  enabled = "${var.enabled * replace(replace(replace(replace(var.regions, "/.*,?us-west-2,?.*/", "XXX"), "/[^X]+/", "Y" ), "XXX", "1"),"/Y+/","0")}"

  environment = "${var.environment}"
  account     = "${var.account}"

  enable_efs = "${var.enable_efs}"

  # memcached
  enable_memcached    = "${var.enable_memcached}"
  memcached_node_size = "${var.memcached_node_size}"
  memcached_num_nodes = "${var.memcached_num_nodes}"

  # redis
  enable_redis    = "${var.enable_redis}"
  redis_node_size = "${var.redis_node_size}"
  redis_num_nodes = "${var.redis_num_nodes}"

  # rds
  enable_rds                  = "${var.enable_rds}"
  mysql_db_name               = "${var.mysql_db_name}"
  mysql_username              = "${var.mysql_username}"
  mysql_password              = "${var.mysql_password}"
  mysql_instance_class        = "${var.mysql_instance_class}"
  mysql_backup_retention_days = "${var.mysql_backup_retention_days}"
  mysql_storage_gb            = "${var.mysql_storage_gb}"
}

module "us-east-1" {
  source = "./tf"

  region = "us-east-1"

  # Okay, somewhat nasty
  #  - take the list of regions, look for the one we care about and make it XXX
  #  - take the result, and make all non-Xes into Ys
  #  - take the result of that (should be either XXX or YYY...)
  #  - change XXX, if found into 1
  #  - change YYY... if found into 0
  #  Result, 1 if the region is found, 0 otherwise
  enabled = "${var.enabled * replace(replace(replace(replace(var.regions, "/.*,?us-east-1,?.*/", "XXX"), "/[^X]+/", "Y" ), "XXX", "1"),"/Y+/","0")}"

  environment = "${var.environment}"
  account     = "${var.account}"

  enable_efs   = "${var.enable_efs}"
  enable_redis = "${var.enable_redis}"
  enable_rds   = "${var.enable_rds}"

  # memcached
  enable_memcached    = "${var.enable_memcached}"
  memcached_node_size = "${var.memcached_node_size}"
  memcached_num_nodes = "${var.memcached_num_nodes}"

  # redis
  enable_redis    = "${var.enable_redis}"
  redis_node_size = "${var.redis_node_size}"
  redis_num_nodes = "${var.redis_num_nodes}"

  # rds
  enable_rds                  = "${var.enable_rds}"
  mysql_db_name               = "${var.mysql_db_name}"
  mysql_username              = "${var.mysql_username}"
  mysql_password              = "${var.mysql_password}"
  mysql_instance_class        = "${var.mysql_instance_class}"
  mysql_backup_retention_days = "${var.mysql_backup_retention_days}"
  mysql_storage_gb            = "${var.mysql_storage_gb}"
}
