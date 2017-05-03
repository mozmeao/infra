variable "region" {}

variable "subnets" {}

variable "pgsql_db_name" {}

variable "pgsql_username" {}

variable "pgsql_password" {}

variable "pgsql_identifier" {}

variable "pgsql_storage" {
  default     = "100"
  description = "Storage size in GB"
}

variable "pgsql_instance_class" {
  default     = "db.m3.xlarge"
  description = "Instance class"
}

variable "pgsql_port" {
  default = 5432
  description = "ingress port to open"
}

variable "pgsql_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "pgsql_engine_version" {
  description = "Engine version"

  default = {
    postgres = "9.6.2"
  }
}

variable "pgsql_backup_retention_days" {
  default     = 3#0
}

variable "vpc_id" {}

variable "cidr_blocks" {
  # we're in the VPC, so let anyone *in the VPC* talk to RDS
  default     = "0.0.0.0/0"
  description = "CIDR for sg"
}
