provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mozilla-careers-s3-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "mozilla-careers-logs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "mozilla-careers" {
  bucket = "mozilla-careers"
  region = "${var.region}"
  acl    = "log-delivery-write"

  force_destroy = ""

  hosted_zone_id = "${lookup(var.hosted-zone-id-defs, var.region)}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "logs/"
  }

  website {
    index_document = "index.html"
  }

  website_domain   = "s3-website-${var.region}.amazonaws.com"
  website_endpoint = "mozilla-careers.s3-website-${var.region}.amazonaws.com"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "careers policy",
  "Statement": [
    {
      "Sid": "careersAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mozilla-careers"
    },
    {
      "Sid": "careersAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mozilla-careers/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "mozilla-careers-stage" {
  bucket = "mozilla-careers-stage"
  region = "${var.region}"
  acl    = "log-delivery-write"

  force_destroy = ""

  hosted_zone_id = "${lookup(var.hosted-zone-id-defs, var.region)}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "stage-logs/"
  }

  website {
    index_document = "index.html"
  }

  website_domain   = "s3-website-${var.region}.amazonaws.com"
  website_endpoint = "mozilla-careers-stage.s3-website-${var.region}.amazonaws.com"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "careers stage policy",
  "Statement": [
    {
      "Sid": "careersStageAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mozilla-careers-stage"
    },
    {
      "Sid": "careersStageAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mozilla-careers-stage/*"
    }
  ]
}
EOF
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "mozilla-careers.s3-website-us-west-2.amazonaws.com"
    origin_id   = "mozilla-careers"
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
    bucket          = "mozilla-careers-logs.s3.amazonaws.com"
    prefix          = "cflogs"
  }

  aliases = ["careers.mozilla.org"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "mozilla-careers"

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
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/6190c26d-0d99-4e45-b460-9bb44bf34f6e"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}


resource "aws_cloudfront_distribution" "stage_s3_distribution" {
  origin {
    domain_name = "mozilla-careers-stage.s3-website-us-west-2.amazonaws.com"
    origin_id   = "mozilla-careersstage"
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
    bucket          = "mozilla-careers-logs.s3.amazonaws.com"
    prefix          = "cflogs-stage"
  }

  aliases = ["careers.allizom.org"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "mozilla-careersstage"

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
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/88572219-24de-43e2-99ba-bcbb8820c319"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}
