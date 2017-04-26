provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mdn-shared-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}

# access is controlled via private IAM policy
# do NOT enable public access to this bucket
resource "aws_s3_bucket" "mdn-db-storage-anonymized" {
  bucket              = "mdn-db-storage-anonymized"
  region              = "${var.region}"
  acceleration_status = "Enabled"
  acl                 = "private"
}

# access is controlled via private IAM policy
# do NOT enable public access to this bucket
resource "aws_s3_bucket" "mdn-db-storage-production" {
  bucket              = "mdn-db-storage-production"
  region              = "${var.region}"
  acceleration_status = "Enabled"
  acl                 = "private"
}

resource "aws_s3_bucket" "mdn-downloads" {
  bucket        = "mdn-downloads"
  region        = "${var.region}"
  acl           = ""
  force_destroy = ""

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  hosted_zone_id = "${lookup(var.hosted-zone-id-defs, var.region)}"

  logging {
    target_bucket = "mdn-downloads"
    target_prefix = "logs/"
  }

  website {
    index_document = "index.html"
  }

  website_domain   = "s3-website-${var.region}.amazonaws.com"
  website_endpoint = "mdn-downloads.s3-website-${var.region}.amazonaws.com"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "mdn-downloads policy",
  "Statement": [
    {
      "Sid": "MDNDownloadAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mdn-downloads"
    },
    {
      "Sid": "MDNDownloadAllowSampledbStar",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mdn-downloads/sampledb/*"
    },
    {
      "Sid": "MDNDownloadAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mdn-downloads/index.html"
    },
    {
      "Sid": "MDNDownloadAllowListDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mdn-downloads/list.html"
    },
    {
      "Sid": "MDNDownloadAllowTarball",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mdn-downloads/developer.mozilla.org.tar.gz"
    },
    {
      "Sid": "MDNDownloadAllowSampleDB",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mdn-downloads/mdn_sample_db.sql.gz"
    },
    {
      "Sid": "MDNDownloadAllowAssetsSlashStar",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mdn-downloads/assets/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "mdn-assets" {
  bucket = "mdn-assets"
  region = "${var.region}"

  logging {
    target_bucket = "mdn-assets"
    target_prefix = "logs/"
  }

  acl = "log-delivery-write"

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::mdn-assets/*"]
    },
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:ListBucket"],
      "Resource":["arn:aws:s3:::mdn-assets"]
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "mdn-legacy" {
  bucket = "mdn-legacy"
  region = "${var.region}"

  logging {
    target_bucket = "mdn-legacy"
    target_prefix = "logs/"
  }

  acl = "log-delivery-write"

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::mdn-legacy/*"]
    },
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:ListBucket"],
      "Resource":["arn:aws:s3:::mdn-legacy"]
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "mdn-legacy-samples" {
  bucket = "mdn-legacy-samples"
  region = "${var.region}"

  logging {
    target_bucket = "mdn-legacy-samples"
    target_prefix = "logs/"
  }

  acl = "log-delivery-write"

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::mdn-legacy-samples/*"]
    },
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:ListBucket"],
      "Resource":["arn:aws:s3:::mdn-legacy-samples"]
    }
  ]
}
EOF
}
