resource "aws_cloudfront_distribution" "snippets" {
  enabled             = "${var.enabled}"
  aliases             = "${var.aliases}"
  price_class         = "PriceClass_100"
  comment             = "${var.comment}"
  http_version        = "http1.1"
  is_ipv6_enabled     = false
  wait_for_deployment = true

  logging_config {
    include_cookies = false
    bucket          = "${var.log_bucket}"
    prefix          = "${var.log_prefix}"
  }

  default_cache_behavior = {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.default_cache_target_origin_id}"

    forwarded_values {
      query_string = true
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 60
    response_page_path    = "/us-west/empty.json"
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "media/*"
    target_origin_id = "${var.ordered_cache_target_origin_id}"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "us-west/*"
    target_origin_id = "${var.ordered_cache_target_origin_id}"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  origin {
    domain_name = "${var.default_cache_target_origin_id}"
    origin_id   = "${var.default_cache_target_origin_id}"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "match-viewer"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1", "SSLv3"]
    }
  }

  origin {
    domain_name = "${var.origin_domain_name}"
    origin_id   = "${var.ordered_cache_target_origin_id}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "${var.certificate_arn}"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }
}

data "aws_route53_zone" "zone" {
  name = "moz.works"
}

resource "aws_route53_record" "snippet_stage_cnames" {
  count = "${length(var.aliases)}"

  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "${var.aliases[count.index]}"
  type    = "CNAME"
  ttl     = 300

  records = ["${aws_cloudfront_distribution.snippets.domain_name}"]
}
