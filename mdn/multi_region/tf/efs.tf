resource "aws_efs_file_system" "mdn-shared" {
  performance_mode = "generalPurpose"
    # also supported, maxIO
  tags {
    Name = "MDN shared"
  }
}

resource "aws_efs_mount_target" "mdn-shared-mt" {
  count = 3
  file_system_id = "${aws_efs_file_system.mdn-shared.id}"
  subnet_id      = "${element(split(",", var.subnets), count.index)}"
}

output "efs_dns_1" {
  value = "${aws_efs_mount_target.mdn-shared-mt.0.dns_name}"
}


output "efs_dns_2" {
  value = "${aws_efs_mount_target.mdn-shared-mt.1.dns_name}"
}
