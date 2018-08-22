
output "interactive-example-bucket" {
  value = "${module.interactive-example.interactive-example-bucket}"
}

output "interactive-example-cloudfront-id" {
  value = "${module.interactive-example.interactive-example-cloudfront-id}"
}

output "interactive-example-cloudfront-domain" {
  value = "${module.interactive-example.interactive-example-cloudfront-domain}"
}
