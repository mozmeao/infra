
variable "mysql_db_name" {}

variable "mysql_username" {}

variable "mysql_password" {}

variable "mysql_identifier" {}

variable "mysql_env" {}

variable "mysql_security_group_name" {}

variable "mysql_storage" {
  default     = "100"
  description = "Storage size in GB"
}

variable "mysql_instance_class" {
  default     = "db.m3.xlarge"
  description = "Instance class"
}

variable "mysql_port" {
  default = 3306
  description = "ingress port to open"
}

variable "mysql_engine" {
  default     = "mysql"
  description = "Engine type, example values mysql, postgres"
}

variable "mysql_engine_version" {
  description = "Engine version"

  default = {
    mysql = "5.6.35"
  }
}

variable "mysql_storage_type" {
  default = "gp2"
}

variable "mysql_backup_retention_days" {
  default     = 7
}

variable "mysql_backup_window" {
  default = "03:00-03:30"
}

variable "mysql_maintenance_window" {
  default = "Sun:04:00-Sun:04:30"
}

variable "mysql_storage_encrypted" {
  default = true
}

variable "mysql_auto_minor_version_upgrade" {
  default = true
}

variable "mysql_allow_major_version_upgrade" {
  default = false
}

variable "vpc_id" { }

variable "vpc_cidr" { }

resource "aws_db_parameter_group" "mdn-params" {
  name        = "${var.mysql_identifier}-params"
  family      = "mysql5.6"
  description = "Paramter group for ${var.mysql_identifier}"

  # https://stackoverflow.com/questions/8744813/mysql-error-2006-hy000-at-line-406-mysql-server-has-gone-away#10709964
  parameter {
    name      = "max_allowed_packet"
    value     = "26214400"
  }
}

resource "aws_db_instance" "mdn_rds" {
  allocated_storage           = "${var.mysql_storage}"
  allow_major_version_upgrade = "${var.mysql_allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.mysql_auto_minor_version_upgrade}"
  backup_retention_period     = "${var.mysql_backup_retention_days}"
  backup_window               = "${var.mysql_backup_window}"
  # note: this resource already existed at time of provisioning from
  # our k8s install automation
  db_subnet_group_name        = "main_subnet_group"
  depends_on                  = ["aws_security_group.mdn_rds_sg"]
  engine                      = "${var.mysql_engine}"
  engine_version              = "${lookup(var.mysql_engine_version, var.mysql_engine)}"
  identifier                  = "${var.mysql_identifier}"
  instance_class              = "${var.mysql_instance_class}"
  maintenance_window          = "${var.mysql_maintenance_window}"
  multi_az                    = true
  name                        = "${var.mysql_db_name}"
  parameter_group_name        = "${aws_db_parameter_group.mdn-params.name}"
  password                    = "${var.mysql_password}"
  publicly_accessible         = false
  storage_encrypted           = "${var.mysql_storage_encrypted}"
  username                    = "${var.mysql_username}"
  vpc_security_group_ids      = ["${aws_security_group.mdn_rds_sg.id}"]
  tags {
    "Stack"                   = "MDN-${var.mysql_env}"
  }
}

resource "aws_security_group" "mdn_rds_sg" {
  name        = "${var.mysql_security_group_name}"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.mysql_port}"
    to_port     = "${var.mysql_port}"
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "mdn_rds_sg"
  }
}
