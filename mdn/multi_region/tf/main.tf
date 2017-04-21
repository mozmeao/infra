provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mdn-multi-region-tf-state"
    key = "tf-state"
    region = "us-west-2"
  }
}
