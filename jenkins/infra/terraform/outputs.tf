
output elb_id {
  value = "${aws_elb.ci.dns_name}"
}

output backup_bucket_name {
  value = "${aws_s3_bucket.ci-backup-bucket.id}"
}
