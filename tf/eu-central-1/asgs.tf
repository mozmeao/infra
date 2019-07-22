resource "aws_autoscaling_group" "master-eu-central-1a-masters-frankfurt-moz-works" {
  desired_capacity          = 1
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "master-eu-central-1a.masters.frankfurt.moz.works-20190418182947676900000002"
  max_size                  = 1
  min_size                  = 1
  name                      = "master-eu-central-1a.masters.frankfurt.moz.works"
  wait_for_capacity_timeout = "10m"
  vpc_zone_identifier       = ["subnet-10685f78"]

  enabled_metrics = ["GroupStandbyInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
  ]

  lifecycle {
    ignore_changes = ["desired_capacity"]
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "frankfurt.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "master-eu-central-1a.masters.frankfurt.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-frankfurt-moz-works" {
  desired_capacity          = 10
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "nodes.frankfurt.moz.works-20190418182947675400000001"
  max_size                  = 22
  min_size                  = 12
  name                      = "nodes.frankfurt.moz.works"
  wait_for_capacity_timeout = "10m"
  vpc_zone_identifier       = ["subnet-10685f78"]

  enabled_metrics = ["GroupStandbyInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
  ]

  load_balancers = [
    "basket-stage",
    "bedrock-prod",
    "bedrock-dev",
    "basket-prod",
    "nucleus-prod",
    "snippets"
  ]

  lifecycle {
    ignore_changes = ["desired_capacity"]
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "frankfurt.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "nodes.frankfurt.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}
