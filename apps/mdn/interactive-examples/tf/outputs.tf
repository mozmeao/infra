
output "interactive-example-bucket" {
  value = "${aws_s3_bucket.interactive-example.id}"
}

output "interactive-example-cloudfront-id" {
  value = "${aws_cloudfront_distribution.s3_distribution.id}"
}

output "interactive-example-cloudfront-domain" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}
