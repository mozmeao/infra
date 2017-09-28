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
  acl                 = "log-delivery-write"

  logging {
    target_bucket = "mdn-db-storage-anonymized"
    target_prefix = "logs/"
  }

  versioning {
    enabled = true
  }

  tags {
     Stack = "MDN-prod"
  }
}

# access is controlled via private IAM policy
# do NOT enable public access to this bucket
resource "aws_s3_bucket" "mdn-db-storage-production" {
  bucket              = "mdn-db-storage-production"
  region              = "${var.region}"
  acceleration_status = "Enabled"
  acl                 = "private"


  logging {
    target_bucket = "mdn-db-storage-production"
    target_prefix = "logs/"
  }

  versioning {
    enabled = true
  }

  tags {
     Stack = "MDN-prod"
  }
}

resource "aws_s3_bucket" "mdn-elb-logs" {
  bucket              = "mdn-elb-logs"
  region              = "${var.region}"
  acl    = "log-delivery-write"
  policy = "${file("mdn-elb-logs.json")}"

  tags {
     Stack = "MDN-prod"
  }
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


  tags {
     Stack = "MDN-prod"
  }

}

# backup EFS to this
resource "aws_s3_bucket" "mdn-shared-backup" {
  bucket              = "mdn-shared-backup"
  region              = "${var.region}"
  acl = "log-delivery-write"

  logging {
    target_bucket = "mdn-shared-backup"
    target_prefix = "logs/"
  }

  versioning {
    enabled = true
  }

  tags {
     Stack = "MDN-prod"
  }

}
