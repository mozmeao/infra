provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "irlpodcast-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}
