provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "irlpodcast-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "irlpodcast-logs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "irlpodcast" {
  bucket = "irlpodcast"
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
  website_endpoint = "irlpodcast.s3-website-${var.region}.amazonaws.com"

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "irlpodcast policy",
  "Statement": [
    {
      "Sid": "IRLPodcastAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::irlpodcast"
    },
    {
      "Sid": "IRLPodcastAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::irlpodcast/*"
    }
  ]
}
EOF
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.irlpodcast.bucket_domain_name}"
    origin_id   = "IRLPodcast"
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

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
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
