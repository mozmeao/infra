
output hosted_zone_id {
  value = "${element(concat(aws_route53_zone.region-zone.*.zone_id, list("")), 0)}"
}
