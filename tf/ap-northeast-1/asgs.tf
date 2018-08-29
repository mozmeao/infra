resource "aws_autoscaling_group" "master-ap-northeast-1a-masters-tokyo-moz-works" {
  desired_capacity          = 1
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "master-ap-northeast-1a.masters.tokyo.moz.works-00ba800a64da6f55df7dfae474"
  max_size                  = 1
  min_size                  = 1
  name                      = "master-ap-northeast-1a.masters.tokyo.moz.works"
  vpc_zone_identifier       = ["subnet-ed79369b"]
  wait_for_capacity_timeout = "10m"

  enabled_metrics = ["GroupStandbyInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
  ]

  tag {
    key                 = "KubernetesCluster"
    value               = "tokyo.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "master-ap-northeast-1a.masters.tokyo.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-tokyo-moz-works" {
  desired_capacity          = 5
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "nodes.tokyo.moz.works-00ba800a64da6f55df7dfae473"
  max_size                  = 20
  min_size                  = 5
  name                      = "nodes.tokyo.moz.works"
  vpc_zone_identifier       = ["subnet-ed79369b"]
  wait_for_capacity_timeout = "10m"

  enabled_metrics = ["GroupStandbyInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
  ]

  load_balancers = ["careers",
    "snippets",
    "basket-stage",
    "bedrock-prod",
    "bedrock-dev",
    "basket-prod",
    "snippets-stats",
    "bedrock-stage",
  ]

  tag {
    key                 = "KubernetesCluster"
    value               = "tokyo.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "nodes.tokyo.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}
