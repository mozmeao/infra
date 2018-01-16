variable "distribution_name" {}
variable "comment" {}
variable "domain_name" {}
variable "acm_cert_arn" {}

variable "aliases" {
  type = "list"
}

resource "aws_cloudfront_distribution" "sumo-cf-dist" {
  aliases         = "${var.aliases}"
  comment         = "${var.comment}"
  enabled         = true
  http_version    = "http2"
  is_ipv6_enabled = false
  price_class     = "PriceClass_All"

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
  }

cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    default_ttl     = 300

    # 86400 = 24 hours
    max_ttl                = 86400
    min_ttl                = 0
    # http://whitenoise.evans.io/en/stable/django.html#restricting-cloudfront-to-static-files
    path_pattern           = "static/*"  
    smooth_streaming       = false
    target_origin_id       = "${var.distribution_name}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    default_ttl     = 300

    # 86400 = 24 hours
    max_ttl                = 86400
    min_ttl                = 0
    
    smooth_streaming       = false
    target_origin_id       = "${var.distribution_name}"
    # http://whitenoise.evans.io/en/stable/django.html#restricting-cloudfront-to-static-files
    # Restrict Viewer Access
    trusted_signers        = "self"       
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = "${var.domain_name}"
    origin_id   = "${var.distribution_name}"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = 5
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.acm_cert_arn}"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}

