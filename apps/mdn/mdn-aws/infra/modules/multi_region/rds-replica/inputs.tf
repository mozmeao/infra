variable "region" {}

variable "environment" {}

variable "enabled" {
  default = 1
}

variable "replica_identifier" {
  default = "mdn"
}

variable "instance_class" {
  default = "db.t2.small"
}

variable "storage_type" {
  default = "gp2"
}

variable "replica_source_db" {}

variable "subnets" {}

variable "kms_key_id" {}

variable "vpc_id" {}

variable "multi_az" {
  default = true
}

variable "mysql_port" {
  default = "3306"
}
