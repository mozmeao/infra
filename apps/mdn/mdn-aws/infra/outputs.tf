output "primary_cdn_domain" {
  value = "${module.mdn_cdn.cdn-primary-dns}"
}

output "attachment_cdn_domain" {
  value = "${module.mdn_cdn.cdn-attachments-dns}"
}

output "downloads_bucket_name" {
  value = "${module.mdn_shared.downloads_bucket_name}"
}

output "downloads_bucket_website" {
  value = "${module.mdn_shared.downloads_bucket_website_endpoint}"
}

output "db_storage_bucket_name" {
  value = "${module.mdn_shared.db_storage_bucket_name}"
}

output "db_storage_anonymized_bucket_name" {
  value = "${module.mdn_shared.db_storage_bucket_anonymized_name}"
}

output "us-west-2-efs-dns" {
  value = "${module.efs-us-west-2.efs-dns}"
}

output "us-west-2-memcached-endpoint" {
  value = "${module.memcached-us-west-2.memcached_endpoint}"
}

output "us-west-2-redis-endpoint" {
  value = "${module.redis-us-west-2.redis_endpoint}"
}

output "us-west-2-rds-endpoint" {
  value = "${module.multi_region.us-west-2.rds_endpoint}"
}
