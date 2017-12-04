variable "bucket_name" {}
variable "region" {}

resource "aws_s3_bucket" "bedrock-bucket" {
  bucket = "${var.bucket_name}"
  region = "${var.region}"
  acl    = "public-read"
}
