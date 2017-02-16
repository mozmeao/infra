provider "aws" {
  region = "${var.region}"
}

# access is controlled via private IAM policy
resource "aws_s3_bucket" "mdn-db-storage-anonymized" {
    bucket = "mdn-db-storage-anonymized"
    region = "${var.region}"
}

# access is controlled via private IAM policy
resource "aws_s3_bucket" "mdn-db-storage-production" {
    bucket = "mdn-db-storage-production"
    region = "${var.region}"
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

}

resource "aws_iam_policy" "mdn-downloads-policy" {
    name = "mdn-downloads-developer"
    description = "IAM policy for MDN S3 downloads"
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
      "Resource": "arn:aws:s3:::mdn-downloads/sample_db.sql.gz"
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

resource "aws_s3_bucket_policy" "mdn-downloads" {
  bucket = "${aws_s3_bucket.mdn-downloads.id}"
  policy = "${aws_iam_policy.mdn-downloads-policy.policy}"
}


/*
Uncomment these when we're ready!
You'll also need the variables in variables.tf

resource "aws_elasticache_cluster" "mdn-redis" {
    cluster_id = "mdn-redis"
    engine = "redis"
    node_type = "${var.cache-node-size}"
    port = "${var.cache-port}"
    num_cache_nodes = "${var.cache-num-nodes}"
    parameter_group_name = "${var.cache-param-group}"
}

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
