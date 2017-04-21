provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mdn-shared-provisioning-tf-state"
    key = "tf-state"
    region = "us-west-2"
  }
}

# access is controlled via private IAM policy
# do NOT enable public access to this bucket
resource "aws_s3_bucket" "mdn-db-storage-anonymized" {
    bucket = "mdn-db-storage-anonymized"
    region = "${var.region}"
    acceleration_status = "Enabled"
}

# access is controlled via private IAM policy
# do NOT enable public access to this bucket
resource "aws_s3_bucket" "mdn-db-storage-production" {
    bucket = "mdn-db-storage-production"
    region = "${var.region}"
    acceleration_status = "Enabled"
}

resource "aws_s3_bucket" "mdn-downloads" {
    bucket = "mdn-downloads"
    region = "${var.region}"
    acl = ""
    force_destroy = ""
    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        max_age_seconds = 3000
    }
    hosted_zone_id="${lookup(var.hosted-zone-id-defs, var.region)}"

    logging {
       target_bucket = "mdn-downloads"
       target_prefix = "logs/"
    }

    website {
      index_document = "index.html"
    }

    website_domain="s3-website-${var.region}.amazonaws.com"
    website_endpoint="mdn-downloads.s3-website-${var.region}.amazonaws.com"
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


/*
Uncomment these when we're ready!
You'll also need the variables in variables.tf

resource "aws_elasticsearch_domain" "mdn-elasticsearch" {
  domain_name           = "mdn-elasticsearch"
  elasticsearch_version = "${var.es-version}"

  cluster_config {
    instance_type  = "${var.es-instance-type}"
    instance_count = "${var.es-instance-count}"
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "${var.es-ebs-volume-type}"
    volume_size = "${var.es-ebs-volume-size}"
  }

  #advanced_options {
  #    "rest.action.multi.allow_explicit_index" = true
  #}

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": "$${var.es-source-ip}"}
            }
        }
    ]
}
CONFIG
  snapshot_options {
    automated_snapshot_start_hour = "${var.es-snapshot-hour}"
  }
  tags {
    Domain = "mdn-elasticsearch"
  }
}
*/
