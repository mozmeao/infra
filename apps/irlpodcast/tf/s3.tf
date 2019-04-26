
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



resource "aws_s3_bucket" "irlpodcast-stage" {
  bucket = "irlpodcast-stage"
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
  website_endpoint = "irlpodcast-stage.s3-website-${var.region}.amazonaws.com"

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "irlpodcast policy",
  "Statement": [
    {
      "Sid": "IRLPodcastStageAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::irlpodcast-stage"
    },
    {
      "Sid": "IRLPodcastStageAllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::irlpodcast-stage/*"
    }
  ]
}
EOF
}
