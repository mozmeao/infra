resource "aws_db_instance" "bedrock_rds" {
  depends_on             = ["aws_security_group.bedrock_rds_sg"]
  identifier             = "${var.pgsql_identifier}"
  allocated_storage      = "${var.pgsql_storage}"
  engine                 = "${var.pgsql_engine}"
  engine_version         = "${lookup(var.pgsql_engine_version, var.pgsql_engine)}"
  instance_class         = "${var.pgsql_instance_class}"
  name                   = "${var.pgsql_db_name}"
  username               = "${var.pgsql_username}"
  password               = "${var.pgsql_password}"
  vpc_security_group_ids = ["${aws_security_group.bedrock_rds_sg.id}"]
  # note: this resource already existed at time of provisioning from
  # our k8s install automation
  db_subnet_group_name   = "main_subnet_group"
  backup_retention_period = "${var.pgsql_backup_retention_days}"
  multi_az = true
}

resource "aws_security_group" "bedrock_rds_sg" {
  name        = "bedrock_rds_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.pgsql_port}"
    to_port     = "${var.pgsql_port}"
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
    Name = "bedrock_rds_sg"
  }
}

