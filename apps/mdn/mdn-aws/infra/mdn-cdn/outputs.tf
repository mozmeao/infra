
output "cdn-attachments-dns" {
  value = "${module.cloudfront-attachments.cdn-attachments-dns}"
}

output "cdn-primary-dns" {
  value = "${module.primary-cloudfront.cdn-primary-dns}"
}
