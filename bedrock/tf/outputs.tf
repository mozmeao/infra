
output "pgsql_db_name" {
  value = "${var.pgsql_db_name}"
}

output "pgsql_password" {
  value = "${var.pgsql_password}"
}

output "pgsql_port" {
  value = "${aws_db_instance.bedrock_rds.port}"
}

output "pgsql_address" {
  value = "${aws_db_instance.bedrock_rds.address}"
}

output "pgsql_endpoint" {
  value = "${aws_db_instance.bedrock_rds.endpoint}"
}

