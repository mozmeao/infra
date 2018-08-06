output "delegation_sets" {
  value = "${join(",", aws_route53_delegation_set.delegation-set.name_servers)}"
}

output "us-west-2-zone-id" {
  value = "${module.us-west-2.hosted_zone_id}"
}
