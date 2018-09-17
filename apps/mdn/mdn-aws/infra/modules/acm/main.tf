data "aws_region" "current" {}

# Just using DNS validation for now
resource aws_acm_certificate "cert" {
  domain_name = "${var.domain_name}"

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Region      = "${data.aws_region.current.name}"
    Service     = "MDN ACM certificate"
  }
}

resource aws_route53_record "cert_validation_dns" {
  count = "${var.acm_validation_method == "DNS" ? 1 : 0}"

  name = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"

  zone_id = "${var.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

# This functions as a waiter, so if validation happens via
# email we don't care we create the cert and move on
resource "aws_acm_certificate_validation" "cert_dns" {
  count = "${var.acm_validation_method == "DNS" ? 1 : 0}"

  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation_dns.fqdn}"]
}
