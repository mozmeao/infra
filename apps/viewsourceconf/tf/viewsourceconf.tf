provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "viewsourceconf-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "viewsourceconf-logs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "viewsourceconf" {
  bucket = "viewsourceconf"
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
  website_endpoint = "viewsourceconf.s3-website-${var.region}.amazonaws.com"

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "viewsourceconf policy",
  "Statement": [
    {
      "Sid": "viewsourceconfAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::viewsourceconf"
    },
    {
      "Sid": "viewsourceconfAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::viewsourceconf/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "viewsourceconf-stage" {
  bucket = "viewsourceconf-stage"
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
  website_endpoint = "viewsourceconf-stage.s3-website-${var.region}.amazonaws.com"

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "viewsourceconf stage policy",
  "Statement": [
    {
      "Sid": "viewsourceconfStageAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::viewsourceconf-stage"
    },
    {
      "Sid": "viewsourceconfStageAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::viewsourceconf-stage/*"
    }
  ]
}
EOF
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "viewsourceconf.s3-website-us-west-2.amazonaws.com"
    origin_id   = "viewsourceconf"
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
    bucket          = "viewsourceconf-logs.s3.amazonaws.com"
    prefix          = "cflogs"
  }

  aliases = ["viewsourceconf.org"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "viewsourceconf"

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
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/92927e4f-8b1a-4d52-9f92-3912151e5dea"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}


resource "aws_cloudfront_distribution" "stage_s3_distribution" {
  origin {
    domain_name = "viewsourceconf-stage.s3-website-us-west-2.amazonaws.com"
    origin_id   = "viewsourceconfstage"
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
    bucket          = "viewsourceconf-logs.s3.amazonaws.com"
    prefix          = "cflogs-stage"
  }

  aliases = ["stage.viewsourceconf.org"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "viewsourceconfstage"

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
    acm_certificate_arn = "arn:aws:acm:us-east-1:236517346949:certificate/57b9d32d-03ec-4e77-9a7a-6fcb6980becc"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}
