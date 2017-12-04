provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "bedrock-shared-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}

module "bedrock-db-dev" {
    source = "./s3"
    bucket_name = "bedrock-db-dev"
    region = "${var.region}"
}

module "bedrock-db-stage" {
    source = "./s3"
    bucket_name = "bedrock-db-stage"
    region = "${var.region}"
}

module "bedrock-db-prod" {
    source = "./s3"
    bucket_name = "bedrock-db-prod"
    region = "${var.region}"
}
