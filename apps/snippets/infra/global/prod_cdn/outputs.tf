output "cdn_id" {
  value = "${aws_cloudfront_distribution.snippets.id}"
}

output "cdn_domain_name" {
  value = "${aws_cloudfront_distribution.snippets.domain_name}"
}
