provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "meaoinfra-tf"
    key    = "ap-northeast-1"
    region = "us-west-2"
  }
}
