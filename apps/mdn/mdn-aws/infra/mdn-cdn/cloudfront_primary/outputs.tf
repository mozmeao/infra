
output "cdn-primary-arn" {
  value = "${element(concat(aws_cloudfront_distribution.mdn-primary-cf-dist.*.arn, list("")), 0)}"
}

output "cdn-primary-dns" {
  value = "${element(concat(aws_cloudfront_distribution.mdn-primary-cf-dist.*.domain_name, list("")), 0)}"
}
