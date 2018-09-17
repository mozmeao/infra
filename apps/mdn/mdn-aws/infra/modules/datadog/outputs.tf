
output "integration_role_arn" {
  value = "${aws_iam_role.datadog_role.arn}"
}

output "aws_account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "datadog_external_id" {
  value = "${var.external_id}"
}
