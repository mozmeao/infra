provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "protocol-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "mozilla-protocol-logs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "protocol" {
  bucket = "mozilla-protocol"
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
    error_document = "404.html"
  }

  website_domain   = "s3-website-${var.region}.amazonaws.com"
  website_endpoint = "mozilla-protocol.s3-website-${var.region}.amazonaws.com"

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "protocol policy",
  "Statement": [
    {
      "Sid": "protocolAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mozilla-protocol"
    },
    {
      "Sid": "protocolAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mozilla-protocol/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "protocol-stage" {
  bucket = "mozilla-protocol-stage"
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
    target_prefix = "stage-logs/"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  website_domain   = "s3-website-${var.region}.amazonaws.com"
  website_endpoint = "mozilla-protocol-stage.s3-website-${var.region}.amazonaws.com"

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "protocol stage policy",
  "Statement": [
    {
      "Sid": "protocolStageAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mozilla-protocol-stage"
    },
    {
      "Sid": "protocolStageAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mozilla-protocol-stage/*"
    }
  ]
}
EOF
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "mozilla-protocol.s3-website-us-west-2.amazonaws.com"
    origin_id   = "protocol"
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
    bucket          = "mozilla-protocol-logs.s3.amazonaws.com"
    prefix          = "cflogs"
  }

  aliases = ["protocol.mozilla.org", "protocol.moz.works"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "protocol"

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
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/53c24b26-dda7-4952-bda1-629be4c88ced"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}


resource "aws_cloudfront_distribution" "stage_s3_distribution" {
  origin {
    domain_name = "protocol-stage.s3-website-us-west-2.amazonaws.com"
    origin_id   = "protocolstage"
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
    bucket          = "mozilla-protocol-logs.s3.amazonaws.com"
    prefix          = "cflogs-stage"
  }

  aliases = ["protocol-stage.moz.works"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "protocolstage"

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
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/e2579ae2-e350-4211-ae47-dd58626f20ee"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}
