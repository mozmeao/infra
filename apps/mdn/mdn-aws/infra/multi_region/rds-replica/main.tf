provider "aws" {
  region = "${var.region}"
}

locals {
  name_prefix = "${var.replica_identifier}-${var.environment}-replica"
}

resource aws_db_subnet_group "replica" {
  name        = "${local.name_prefix}-subnet-group"
  description = "${local.name_prefix}-subnet-group"

  subnet_ids = ["${split(",", var.subnets)}"]

  tags {
    Name        = "${local.name_prefix}-subnet-group"
    Environment = "${var.environment}"
    Region      = "${var.region}"
  }
}

resource aws_db_instance "replica" {
  count = "${var.enabled}"

  identifier          = "${local.name_prefix}"
  replicate_source_db = "${var.replica_source_db}"
  instance_class      = "${var.instance_class}"
  storage_type        = "${var.storage_type}"
  kms_key_id          = "${var.kms_key_id}"

  vpc_security_group_ids = ["${aws_security_group.replica-sg.id}"]
  multi_az               = "${var.multi_az}"

  apply_immediately   = true
  skip_final_snapshot = true

  tags {
    Name        = "${local.name_prefix}"
    Region      = "${var.region}"
    Environment = "${var.environment}"
  }
}

data aws_vpc "vpc_cidr" {
  id = "${var.vpc_id}"
}

resource "aws_security_group" "replica-sg" {
  count = "${var.enabled}"
  name  = "${local.name_prefix}-sg"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = "${var.mysql_port}"
    to_port     = "${var.mysql_port}"
    protocol    = "TCP"
    cidr_blocks = ["${data.aws_vpc.vpc_cidr.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${local.name_prefix}-sg"
    Environment = "${var.environment}"
    Region      = "${var.region}"
  }
}
