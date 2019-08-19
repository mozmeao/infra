resource "aws_cloudfront_distribution" "snippets" {
  enabled             = "${var.enabled}"
  aliases             = "${var.aliases}"
  price_class         = "PriceClass_All"
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
    target_origin_id = "snippets.mozilla.com"

    forwarded_values {
      query_string = true
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "media/*"
    target_origin_id = "S3-snippets-prod-us-west"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "us-west/*"
    target_origin_id = "S3-snippets-prod-us-west"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  # Cache behavior with precedence 2
  ordered_cache_behavior {
    path_pattern     = "eu-west/*"
    target_origin_id = "S3-snippets-prod-eu-west"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  # Cache behavior with precedence 3
  ordered_cache_behavior {
    path_pattern     = "us-east/*"
    target_origin_id = "s3-prod-us-east"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  # Cache behavior with precedence 4
  ordered_cache_behavior {
    path_pattern     = "tokyo/*"
    target_origin_id = "s3-prod-tokyo"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  # Cache behavior with precedence 5
  ordered_cache_behavior {
    path_pattern     = "frankfurt/*"
    target_origin_id = "s3-prod-frankfurt"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    compress               = true
    min_ttl                = "0"
    max_ttl                = "31536000"
    default_ttl            = "86400"
  }

  # origin 1
  origin {
    domain_name = "s3-ap-northeast-1.amazonaws.com"
    origin_id   = "s3-prod-tokyo"
    origin_path = "/snippets-prod-tokyo"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # origin 2
  origin {
    domain_name = "snippets.mozilla.com"
    origin_id   = "snippets.mozilla.com"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "match-viewer"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1", "SSLv3"]
    }
  }

  # origin 3
  origin {
    domain_name = "s3.amazonaws.com"
    origin_id   = "s3-prod-us-east"
    origin_path = "/snippets-prod-us-east"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = "snippets-prod-us-west.s3.amazonaws.com"
    origin_id   = "S3-snippets-prod-us-west"
  }

  origin {
    domain_name = "snippets-prod-eu-west.s3.amazonaws.com"
    origin_id   = "S3-snippets-prod-eu-west"
  }

  origin {
    domain_name = "snippets-prod-frankfurt.s3.amazonaws.com"
    origin_id   = "s3-prod-frankfurt"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    #acm_certificate_arn            = "arn:aws:acm:us-east-1:369987351092:certificate/5f5d4ff6-3a5a-416f-9990-e8201558eab8"
    acm_certificate_arn            = "${var.certificate_arn}"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "vip"
  }
}
