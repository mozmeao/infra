# dev

resource "aws_efs_file_system" "mdn-shared-dev" {
  performance_mode = "generalPurpose"
  tags {
    Name = "mdn-shared-dev"
  }
}

resource "aws_efs_mount_target" "mdn-shared-dev-mt" {
  # split the subnet variable into a list, then take the length of the list
  count           = "${length(split(",", var.subnets))}"
  # use the EFS filesystem we created above
  file_system_id = "${aws_efs_file_system.mdn-shared-dev.id}"
  # split the subnet variable into a list, then get the count.index subnet id
  subnet_id      = "${element(split(",", var.subnets), count.index)}"
  security_groups = ["${var.nodes_security_group}"]
}


# stage

resource "aws_efs_file_system" "mdn-shared-stage" {
  performance_mode = "generalPurpose"
  tags {
    Name = "mdn-shared-stage"
  }
}

resource "aws_efs_mount_target" "mdn-shared-stage-mt" {
  # split the subnet variable into a list, then take the length of the list
  count           = "${length(split(",", var.subnets))}"
  # use the EFS filesystem we created above
  file_system_id = "${aws_efs_file_system.mdn-shared-stage.id}"
  # split the subnet variable into a list, then get the count.index subnet id
  subnet_id      = "${element(split(",", var.subnets), count.index)}"
  security_groups = ["${var.nodes_security_group}"]
}


# prod

resource "aws_efs_file_system" "mdn-shared-prod" {
  performance_mode = "generalPurpose"
  tags {
    Name = "mdn-shared-prod"
  }
}

resource "aws_efs_mount_target" "mdn-shared-prod-mt" {
  # split the subnet variable into a list, then take the length of the list
  count           = "${length(split(",", var.subnets))}"
  # use the EFS filesystem we created above
  file_system_id = "${aws_efs_file_system.mdn-shared-prod.id}"
  # split the subnet variable into a list, then get the count.index subnet id
  subnet_id      = "${element(split(",", var.subnets), count.index)}"
  security_groups = ["${var.nodes_security_group}"]
}
