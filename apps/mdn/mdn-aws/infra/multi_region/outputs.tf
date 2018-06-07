output us-west-2-efs-dns {
  value = "${module.us-west-2.efs_dns}"
}

output us-west-2-memcached_endpoint {
  value = "${module.us-west-2.memcached_endpoint}"
}

output us-west-2-redis_endpoint {
  value = "${module.us-west-2.redis_endpoint}"
}

output us-west-2-rds_endpoint {
  value = "${module.us-west-2.rds_endpoint}"
}

output us-west-2-rds_address {
  value = "${module.us-west-2.rds_address}"
}
