provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "awebpodcast-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}
