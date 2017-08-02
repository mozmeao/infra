output "efs_dev_dns" {
  # all AZ's return the same dns name, just use the first
  value = "${aws_efs_mount_target.mdn-shared-dev-mt.0.dns_name}"
}
