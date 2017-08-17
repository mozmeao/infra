
variable "mysql_db_name" {}

variable "mysql_username" {}

variable "mysql_password" {}

variable "mysql_identifier" {}

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

variable "vpc_id" {}

variable "cidr_blocks" {
  # we're in the VPC, so let anyone *in the VPC* talk to RDS
  default     = "0.0.0.0/0"
  description = "CIDR for sg"
}


resource "aws_db_instance" "mdn_rds" {
  depends_on                  = ["aws_security_group.mdn_rds_sg"]
  identifier                  = "${var.mysql_identifier}"
  allocated_storage           = "${var.mysql_storage}"
  engine                      = "${var.mysql_engine}"
  engine_version              = "${lookup(var.mysql_engine_version, var.mysql_engine)}"
  instance_class              = "${var.mysql_instance_class}"
  name                        = "${var.mysql_db_name}"
  username                    = "${var.mysql_username}"
  password                    = "${var.mysql_password}"
  vpc_security_group_ids      = ["${aws_security_group.mdn_rds_sg.id}"]
  # note: this resource already existed at time of provisioning from
  # our k8s install automation
  db_subnet_group_name        = "main_subnet_group"
  backup_retention_period     = "${var.mysql_backup_retention_days}"
  multi_az                    = true
  backup_window               = "${var.mysql_backup_window}"
  maintenance_window          = "${var.mysql_maintenance_window}"
  publicly_accessible         = false
  storage_encrypted           = "${var.mysql_storage_encrypted}"
  auto_minor_version_upgrade  = "${var.mysql_auto_minor_version_upgrade}"
  allow_major_version_upgrade = "${var.mysql_allow_major_version_upgrade}"
}

resource "aws_security_group" "mdn_rds_sg" {
  name        = "mdn_rds_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.mysql_port}"
    to_port     = "${var.mysql_port}"
    protocol    = "TCP"
    cidr_blocks = ["${var.cidr_blocks}"]
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
