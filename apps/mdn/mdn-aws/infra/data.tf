provider "aws" {
  alias  = "data-eu-central-1"
  region = "eu-central-1"
}

data terraform_remote_state "dns" {
  backend = "s3"

  config = {
    bucket = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key    = "terraform/dns"
    region = "us-west-2"
  }
}

data terraform_remote_state "kubernetes-us-west-2" {
  backend = "s3"

  config {
    bucket = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key    = "terraform/kubernetes-us-west-2a"
    region = "us-west-2"
  }
}

data terraform_remote_state "kubernetes-eu-central-1" {
  backend = "s3"

  config  = {
    bucket  = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key     = "terraform/kubernetes-eu-central-1a"
    region  = "us-west-2"
  }
}

data aws_vpc "cidr" {
  id = "${data.terraform_remote_state.kubernetes-us-west-2.vpc_id}"
}

data aws_subnet_ids "subnet_id" {
  vpc_id = "${data.terraform_remote_state.kubernetes-us-west-2.vpc_id}"
}

data aws_subnet_ids "eu-central-subnet_ids" {
  provider = "aws.data-eu-central-1"
  vpc_id  = "${data.terraform_remote_state.kubernetes-eu-central-1.vpc_id}"
}
