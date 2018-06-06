provider "aws" {
  region = "${var.region}"
}

resource "random_id" "rand-var" {
  count = "${var.enabled}"

  keepers = {
    db_storage_bucket_name = "${var.db_storage_bucket_name}"
    elb_logs_bucket_name   = "${var.elb_logs_bucket_name}"
    downloads_bucket_name  = "${var.downloads_bucket_name}"
  }

  byte_length = 8
}

locals {
  db_storage            = "${var.db_storage_bucket_name}-${var.environment}-${random_id.rand-var.hex}"
  db_storage_anonymized = "${var.db_storage_bucket_name}-anonymized-${var.environment}-${random_id.rand-var.hex}"
  elb_logs              = "${var.elb_logs_bucket_name}-${var.environment}-${random_id.rand-var.hex}"
  downloads             = "${var.downloads_bucket_name}-${var.environment}-${random_id.rand-var.hex}"
  shared_backup         = "${var.shared_backup_bucket_name}-${var.environment}-${random_id.rand-var.hex}"
}

# access is controlled via private IAM policy
# do NOT enable public access to this bucket
resource "aws_s3_bucket" "mdn-db-storage-anonymized" {
  bucket              = "${local.db_storage_anonymized}"
  region              = "${var.region}"
  acceleration_status = "Enabled"
  acl                 = "log-delivery-write"

  logging {
    target_bucket = "${local.db_storage_anonymized}"
    target_prefix = "logs/"
  }

  versioning {
    enabled = true
  }

  tags {
    Name        = "${local.db_storage_anonymized}"
    Stack       = "MDN-${var.environment}"
    Environment = "${var.environment}"
    Purpose     = "db-storage"
  }
}

# access is controlled via private IAM policy
# do NOT enable public access to this bucket
resource "aws_s3_bucket" "mdn-db-storage" {
  count = "${var.enabled}"

  bucket              = "${local.db_storage}"
  region              = "${var.region}"
  acceleration_status = "Enabled"
  acl                 = "private"

  logging {
    target_bucket = "${local.db_storage}"
    target_prefix = "logs/"
  }

  versioning {
    enabled = true
  }

  tags {
    Name        = "${local.db_storage}"
    Stack       = "MDN-${var.environment}"
    Environment = "${var.environment}"
    Purpose     = "db-storage"
  }
}

resource "aws_s3_bucket" "mdn-elb-logs" {
  count = "${var.enabled}"

  bucket = "${local.elb_logs}"
  region = "${var.region}"
  acl    = "log-delivery-write"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "AWSConsole-AccessLogs-Policy-1503002510675",
    "Statement": [
        {
            "Sid": "AWSConsoleStmt-1503002510675",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::797873946194:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.elb_logs}/*"
        }
    ]
}
EOF

  tags {
    Name        = "${local.elb_logs}"
    Stack       = "MDN-${var.environment}"
    Environment = "${var.environment}"
    Purpose     = "elb-logs"
  }
}

resource "aws_s3_bucket" "mdn-downloads" {
  count         = "${var.enabled}"
  bucket        = "${local.downloads}"
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
    target_bucket = "${local.downloads}"
    target_prefix = "logs/"
  }

  website {
    index_document = "index.html"
  }

  website_domain   = "s3-website-${var.region}.amazonaws.com"
  website_endpoint = "${local.downloads}.s3-website-${var.region}.amazonaws.com"

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
      "Resource": "arn:aws:s3:::${local.downloads}"
    },
    {
      "Sid": "MDNDownloadAllowSampledbStar",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.downloads}/sampledb/*"
    },
    {
      "Sid": "MDNDownloadAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.downloads}/index.html"
    },
    {
      "Sid": "MDNDownloadAllowListDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.downloads}/list.html"
    },
    {
      "Sid": "MDNDownloadAllowTarball",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.downloads}/developer.mozilla.org.tar.gz"
    },
    {
      "Sid": "MDNDownloadAllowSampleDB",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.downloads}/mdn_sample_db.sql.gz"
    },
    {
      "Sid": "MDNDownloadAllowAssetsSlashStar",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.downloads}/assets/*"
    }
  ]
}
EOF

  tags {
    Name        = "${local.downloads}"
    Stack       = "MDN-${var.environment}"
    Environment = "${var.environment}"
  }
}

# backup EFS to this
resource "aws_s3_bucket" "mdn-shared-backup" {
  count  = "${var.enabled}"
  bucket = "${local.shared_backup}"
  region = "${var.region}"
  acl    = "log-delivery-write"

  logging {
    target_bucket = "${local.shared_backup}"
    target_prefix = "logs/"
  }

  versioning {
    enabled = true
  }

  tags {
    Name        = "${local.shared_backup}"
    Stack       = "MDN-${var.environment}"
    Environment = "${var.environment}"
  }
}
