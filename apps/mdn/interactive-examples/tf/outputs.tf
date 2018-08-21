
output "interactive_example_bucket" {
  value = "${aws_s3_bucket.mdninteractive.id}"
}

output "interactive_example_cloudfront_id" {
  value = "${aws_cloudfront_distribution.s3_distribution.id}"
}

output "interactive_example_cloudfront_domain" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}
