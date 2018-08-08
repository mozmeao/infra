
terraform {
  backend "s3" {
    bucket = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key    = "terraform/kubernetes-us-west-2a"
    region = "us-west-2"
  }
}

provider aws {
  region = "${var.region}"
}

module "kubernetes" {
  source = "./out/terraform"
}
