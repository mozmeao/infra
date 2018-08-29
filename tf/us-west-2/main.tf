provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "meaoinfra-tf"
    key    = "us-west-2"
    region = "us-west-2"
  }
}
