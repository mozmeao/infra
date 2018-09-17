
output replica_rds_id {
  value = "${element(concat(aws_db_instance.replica.*.id, list("")), 0)}"
}
