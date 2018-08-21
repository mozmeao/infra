resource "random_id" "rand-var" {
  keepers = {
    mdn-interactive-bucket = "${var.mdn-interactive-bucket}"
  }

  byte_length = 8
}

locals {
  interactive-bucket      = "${var.mdn-interactive-bucket}-${random_id.rand-var.hex}"
  interactive-bucket-logs = "${var.mdn-interactive-bucket}-${random_id.rand-var.hex}-logs"
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.interactive-bucket-logs}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "mdninteractive" {
  bucket = "${local.interactive-bucket}"
  region = "${var.region}"
  acl    = "log-delivery-write"

  force_destroy = ""

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  hosted_zone_id = "${lookup(var.hosted-zone-id-defs, var.region)}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.id}"
    target_prefix = "logs/"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  website_domain   = "s3-website-${var.region}.amazonaws.com"
  website_endpoint = "${local.interactive-bucket}.s3-website-${var.region}.amazonaws.com"

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "mdninteractive policy",
  "Statement": [
    {
      "Sid": "MDNInteractiveAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${local.interactive-bucket}"
    },
    {
      "Sid": "MDNInteractiveAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.interactive-bucket}/*"
    }
  ]
}
EOF
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${local.interactive-bucket}.s3-website-${var.region}.amazonaws.com"
    origin_id   = "MDNInteractive"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "No comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${local.interactive-bucket-logs}.s3.amazonaws.com"
    prefix          = "cflogs"
  }

  aliases = [
    # FIXME: Can't use mdn.mozilla.net because its already taken
    # assuming its from whats running in prod right now
    #"interactive-examples.mdn.mozilla.net",
    "interactive-examples.mdn.mozit.cloud",
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "MDNInteractive"
    compress         = true

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
    acm_certificate_arn = "${var.acm_certificate_arn}"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}
