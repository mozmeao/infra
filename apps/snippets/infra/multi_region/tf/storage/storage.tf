variable "region" {}

variable "environment" {}

variable "region_short" {}

resource "aws_s3_bucket" "logs" {
  bucket = "snippets-${var.environment}-${var.region_short}-logs"
  region = "${var.region}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "bundles" {
  depends_on = ["aws_s3_bucket.logs"]
  bucket     = "snippets-${var.environment}-${var.region_short}"
  region     = "${var.region}"
  acl        = "public-read"

  policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::snippets-${var.environment}-${var.region_short}/*",
      "Principal": "*"
    }
  ]
}
EOF

  lifecycle_rule {
    id      = "bundles"
    prefix  = "${var.region_short}/bundles"
    enabled = true

    expiration {
      days = 60
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "snippets-${var.environment}-${var.region_short}-logs"
    target_prefix = "log/"
  }

  cors_rule {
    allowed_headers = ["GET", "OPTIONS", "HEAD"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 900
  }
}
