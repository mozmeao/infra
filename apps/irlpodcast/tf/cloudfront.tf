
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "irlpodcast.s3-website-us-west-2.amazonaws.com"
    origin_id   = "IRLPodcast"
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      https_port = "443"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "No comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "irlpodcast-logs.s3.amazonaws.com"
    prefix          = "cflogs"
  }

  aliases = ["irlpodcast.org"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "IRLPodcast"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
          event_type = "viewer-response"
          lambda_arn = "${aws_lambda_function.prod-lambda-headers.qualified_arn}"
    }


    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/dfb1a424-f70d-4c5c-81c6-dd174f455830"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}

resource "aws_cloudfront_distribution" "www_s3_distribution" {
  origin {
    domain_name = "irlpodcast.s3-website-us-west-2.amazonaws.com"
    origin_id   = "WWWIRLPodcast"
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      https_port = "443"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "No comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "irlpodcast-logs.s3.amazonaws.com"
    prefix          = "cflogs_www"
  }

  aliases = ["www.irlpodcast.org"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "WWWIRLPodcast"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
            event_type = "viewer-request"
            lambda_arn = "${aws_lambda_function.www-prod-lambda.qualified_arn}"
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/dfb1a424-f70d-4c5c-81c6-dd174f455830"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}


resource "aws_cloudfront_distribution" "stage_s3_distribution" {
  origin {
    domain_name = "irlpodcast-stage.s3-website-us-west-2.amazonaws.com"
    origin_id   = "IRLPodcastStage"
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      https_port = "443"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "No comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "irlpodcast-logs.s3.amazonaws.com"
    prefix          = "cflogs-stage"
  }

  aliases = ["stage.irlpodcast.org"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "IRLPodcastStage"

    lambda_function_association {
          event_type = "viewer-response"
          lambda_arn = "${aws_lambda_function.stage-lambda-headers.qualified_arn}"
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/841fb67c-df15-44ab-90cd-0fc2a51115a6"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}
