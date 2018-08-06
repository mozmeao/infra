resource aws_route53_zone "region-zone" {
  name = "${var.region}.${var.domain_name}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name    = "${var.region}.${var.domain_name}"
    Purpose = "Region stub zone"
    Region  = "${var.region}"
  }
}

resource aws_route53_record "region-hosted-record" {
  zone_id = "${var.zone_id}"
  name    = "${var.region}"

  type  = "NS"
  ttl   = "86400"

  records = [
    "${aws_route53_zone.region-zone.name_servers}"
  ]

}
