provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "meaoinfra-tf"
    key    = "eu-central-1"
    region = "us-west-2"
  }
}

