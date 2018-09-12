locals = {
  cluster_name                 = "k8s.eu-central-1a.mdn.mozit.cloud"
  master_autoscaling_group_ids = ["${aws_autoscaling_group.master-eu-central-1a-masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
  master_security_group_ids    = ["${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
  masters_role_arn             = "${aws_iam_role.masters-k8s-eu-central-1a-mdn-mozit-cloud.arn}"
  masters_role_name            = "${aws_iam_role.masters-k8s-eu-central-1a-mdn-mozit-cloud.name}"
  node_autoscaling_group_ids   = ["${aws_autoscaling_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
  node_security_group_ids      = ["${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
  node_subnet_ids              = ["${aws_subnet.eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
  nodes_role_arn               = "${aws_iam_role.nodes-k8s-eu-central-1a-mdn-mozit-cloud.arn}"
  nodes_role_name              = "${aws_iam_role.nodes-k8s-eu-central-1a-mdn-mozit-cloud.name}"
  region                       = "eu-central-1"
  route_table_public_id        = "${aws_route_table.k8s-eu-central-1a-mdn-mozit-cloud.id}"
  subnet_eu-central-1a_id      = "${aws_subnet.eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  vpc_cidr_block               = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.cidr_block}"
  vpc_id                       = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.id}"
}

output "cluster_name" {
  value = "k8s.eu-central-1a.mdn.mozit.cloud"
}

output "master_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.master-eu-central-1a-masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-k8s-eu-central-1a-mdn-mozit-cloud.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-k8s-eu-central-1a-mdn-mozit-cloud.name}"
}

output "node_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-k8s-eu-central-1a-mdn-mozit-cloud.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-k8s-eu-central-1a-mdn-mozit-cloud.name}"
}

output "region" {
  value = "eu-central-1"
}

output "route_table_public_id" {
  value = "${aws_route_table.k8s-eu-central-1a-mdn-mozit-cloud.id}"
}

output "subnet_eu-central-1a_id" {
  value = "${aws_subnet.eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.cidr_block}"
}

output "vpc_id" {
  value = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.id}"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_autoscaling_group" "master-eu-central-1a-masters-k8s-eu-central-1a-mdn-mozit-cloud" {
  name                 = "master-eu-central-1a.masters.k8s.eu-central-1a.mdn.mozit.cloud"
  launch_configuration = "${aws_launch_configuration.master-eu-central-1a-masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "k8s.eu-central-1a.mdn.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-eu-central-1a.masters.k8s.eu-central-1a.mdn.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-eu-central-1a"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-k8s-eu-central-1a-mdn-mozit-cloud" {
  name                 = "nodes.k8s.eu-central-1a.mdn.mozit.cloud"
  launch_configuration = "${aws_launch_configuration.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  max_size             = 3
  min_size             = 3
  vpc_zone_identifier  = ["${aws_subnet.eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "k8s.eu-central-1a.mdn.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.k8s.eu-central-1a.mdn.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "a-etcd-events-k8s-eu-central-1a-mdn-mozit-cloud" {
  availability_zone = "eu-central-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "a.etcd-events.k8s.eu-central-1a.mdn.mozit.cloud"
    "k8s.io/etcd/events"                                      = "a/a"
    "k8s.io/role/master"                                      = "1"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
  }
}

resource "aws_ebs_volume" "a-etcd-main-k8s-eu-central-1a-mdn-mozit-cloud" {
  availability_zone = "eu-central-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "a.etcd-main.k8s.eu-central-1a.mdn.mozit.cloud"
    "k8s.io/etcd/main"                                        = "a/a"
    "k8s.io/role/master"                                      = "1"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
  }
}

resource "aws_iam_instance_profile" "masters-k8s-eu-central-1a-mdn-mozit-cloud" {
  name = "masters.k8s.eu-central-1a.mdn.mozit.cloud"
  role = "${aws_iam_role.masters-k8s-eu-central-1a-mdn-mozit-cloud.name}"
}

resource "aws_iam_instance_profile" "nodes-k8s-eu-central-1a-mdn-mozit-cloud" {
  name = "nodes.k8s.eu-central-1a.mdn.mozit.cloud"
  role = "${aws_iam_role.nodes-k8s-eu-central-1a-mdn-mozit-cloud.name}"
}

resource "aws_iam_role" "masters-k8s-eu-central-1a-mdn-mozit-cloud" {
  name               = "masters.k8s.eu-central-1a.mdn.mozit.cloud"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.k8s.eu-central-1a.mdn.mozit.cloud_policy")}"
}

resource "aws_iam_role" "nodes-k8s-eu-central-1a-mdn-mozit-cloud" {
  name               = "nodes.k8s.eu-central-1a.mdn.mozit.cloud"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.k8s.eu-central-1a.mdn.mozit.cloud_policy")}"
}

resource "aws_iam_role_policy" "masters-k8s-eu-central-1a-mdn-mozit-cloud" {
  name   = "masters.k8s.eu-central-1a.mdn.mozit.cloud"
  role   = "${aws_iam_role.masters-k8s-eu-central-1a-mdn-mozit-cloud.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.k8s.eu-central-1a.mdn.mozit.cloud_policy")}"
}

resource "aws_iam_role_policy" "nodes-k8s-eu-central-1a-mdn-mozit-cloud" {
  name   = "nodes.k8s.eu-central-1a.mdn.mozit.cloud"
  role   = "${aws_iam_role.nodes-k8s-eu-central-1a-mdn-mozit-cloud.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.k8s.eu-central-1a.mdn.mozit.cloud_policy")}"
}

resource "aws_internet_gateway" "k8s-eu-central-1a-mdn-mozit-cloud" {
  vpc_id = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.id}"

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "k8s.eu-central-1a.mdn.mozit.cloud"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
  }
}

resource "aws_key_pair" "kubernetes-k8s-eu-central-1a-mdn-mozit-cloud-44ff04d0bf8934c5c30d253bd7df3bef" {
  key_name   = "kubernetes.k8s.eu-central-1a.mdn.mozit.cloud-44:ff:04:d0:bf:89:34:c5:c3:0d:25:3b:d7:df:3b:ef"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.k8s.eu-central-1a.mdn.mozit.cloud-44ff04d0bf8934c5c30d253bd7df3bef_public_key")}"
}

resource "aws_launch_configuration" "master-eu-central-1a-masters-k8s-eu-central-1a-mdn-mozit-cloud" {
  name_prefix                 = "master-eu-central-1a.masters.k8s.eu-central-1a.mdn.mozit.cloud-"
  image_id                    = "ami-a92b43c6"
  instance_type               = "m4.large"
  key_name                    = "${aws_key_pair.kubernetes-k8s-eu-central-1a-mdn-mozit-cloud-44ff04d0bf8934c5c30d253bd7df3bef.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  security_groups             = ["${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-eu-central-1a.masters.k8s.eu-central-1a.mdn.mozit.cloud_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 250
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-k8s-eu-central-1a-mdn-mozit-cloud" {
  name_prefix                 = "nodes.k8s.eu-central-1a.mdn.mozit.cloud-"
  image_id                    = "ami-a92b43c6"
  instance_type               = "m4.xlarge"
  key_name                    = "${aws_key_pair.kubernetes-k8s-eu-central-1a-mdn-mozit-cloud-44ff04d0bf8934c5c30d253bd7df3bef.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  security_groups             = ["${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.k8s.eu-central-1a.mdn.mozit.cloud_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 250
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.k8s-eu-central-1a-mdn-mozit-cloud.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.k8s-eu-central-1a-mdn-mozit-cloud.id}"
}

resource "aws_route_table" "k8s-eu-central-1a-mdn-mozit-cloud" {
  vpc_id = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.id}"

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "k8s.eu-central-1a.mdn.mozit.cloud"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
    "kubernetes.io/kops/role"                                 = "public"
  }
}

resource "aws_route_table_association" "eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud" {
  subnet_id      = "${aws_subnet.eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  route_table_id = "${aws_route_table.k8s-eu-central-1a-mdn-mozit-cloud.id}"
}

resource "aws_security_group" "masters-k8s-eu-central-1a-mdn-mozit-cloud" {
  name        = "masters.k8s.eu-central-1a.mdn.mozit.cloud"
  vpc_id      = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "masters.k8s.eu-central-1a.mdn.mozit.cloud"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
  }
}

resource "aws_security_group" "nodes-k8s-eu-central-1a-mdn-mozit-cloud" {
  name        = "nodes.k8s.eu-central-1a.mdn.mozit.cloud"
  vpc_id      = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "nodes.k8s.eu-central-1a.mdn.mozit.cloud"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "https-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-protocol-ipip" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4001" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port                = 2382
  to_port                  = 4001
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-k8s-eu-central-1a-mdn-mozit-cloud.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "eu-central-1a-k8s-eu-central-1a-mdn-mozit-cloud" {
  vpc_id            = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "eu-central-1a"

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "eu-central-1a.k8s.eu-central-1a.mdn.mozit.cloud"
    SubnetType                                                = "Public"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
    "kubernetes.io/role/elb"                                  = "1"
  }
}

resource "aws_vpc" "k8s-eu-central-1a-mdn-mozit-cloud" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "k8s.eu-central-1a.mdn.mozit.cloud"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "k8s-eu-central-1a-mdn-mozit-cloud" {
  domain_name         = "eu-central-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster                                         = "k8s.eu-central-1a.mdn.mozit.cloud"
    Name                                                      = "k8s.eu-central-1a.mdn.mozit.cloud"
    "kubernetes.io/cluster/k8s.eu-central-1a.mdn.mozit.cloud" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "k8s-eu-central-1a-mdn-mozit-cloud" {
  vpc_id          = "${aws_vpc.k8s-eu-central-1a-mdn-mozit-cloud.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.k8s-eu-central-1a-mdn-mozit-cloud.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}
