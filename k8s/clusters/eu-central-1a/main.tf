terraform {
  backend "s3" {
    bucket = "mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
    key    = "terraform/kubernetes-eu-central-1a"
    region = "us-west-2"
  }
}

provider aws {
  region = "${var.region}"
}

module "kubernetes" {
  source = "./out/terraform"
}

# This is added after cluster creation
resource aws_subnet "eu-central-1b-k8s-eu-central-1a-mdn-mozit-cloud" {
  vpc_id            = "${module.kubernetes.vpc_id}"
  cidr_block        = "172.20.64.0/19"
  availability_zone = "eu-central-1b"

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "eu-central-1b.k8s.eu-central-1a.mdn.mozit.cloud"
    SubnetType                                                = "Public"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
    "kubernetes.io/role/elb"                                  = "1"
  }
}

resource aws_subnet "eu-central-1c-k8s-eu-central-1a-mdn-mozit-cloud" {
  vpc_id            = "${module.kubernetes.vpc_id}"
  cidr_block        = "172.20.96.0/19"
  availability_zone = "eu-central-1c"

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "eu-central-1c.k8s.eu-central-1a.mdn.mozit.cloud"
    SubnetType                                                = "Public"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
    "kubernetes.io/role/elb"                                  = "1"
  }
}
