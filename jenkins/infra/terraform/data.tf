data terraform_remote_state "kubernetes-us-west-2" {
  backend = "s3"

  config {
    bucket = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key    = "terraform/kubernetes-us-west-2a"
    region = "us-west-2"
  }
}

data aws_subnet_ids "subnet_id" {
  vpc_id = "${data.terraform_remote_state.kubernetes-us-west-2.vpc_id}"
}

data aws_ami "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data aws_acm_certificate "ci" {
  domain   = "ci.us-west-2.mdn.mozit.cloud"
  statuses = ["ISSUED"]
}
