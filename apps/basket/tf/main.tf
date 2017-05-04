provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "basket-multi-region-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}
