resource "aws_autoscaling_group" "master-us-west-2a-masters-oregon-a-moz-works" {
  desired_capacity          = 1
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "master-us-west-2a.masters.oregon-a.moz.works-20190920165600157100000001"
  max_size                  = 1
  min_size                  = 1
  metrics_granularity       = "1Minute"
  name                      = "master-us-west-2a.masters.oregon-a.moz.works"
  vpc_zone_identifier       = ["subnet-0d89cd37ecec22dd2"]
  wait_for_capacity_timeout = "10m"

  enabled_metrics = [
      "GroupStandbyInstances",
      "GroupTotalInstances",
      "GroupPendingInstances",
      "GroupTerminatingInstances",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupMinSize",
      "GroupMaxSize"
  ]

  lifecycle {
    ignore_changes = ["force_delete",
      "metrics_granularity",
      "wait_for_capacity_timeout",
      "desired_capacity",
    ]
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "oregon-a.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "master-us-west-2a.masters.oregon-a.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-2a"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "master-us-west-2b-masters-oregon-b-moz-works" {
  desired_capacity          = 1
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "master-us-west-2b.masters.oregon-b.moz.works-20191001193310824000000001"
  max_size                  = 1
  min_size                  = 1
  metrics_granularity       = "1Minute"
  name                      = "master-us-west-2b.masters.oregon-b.moz.works"
  vpc_zone_identifier       = ["subnet-e290afaa"]
  wait_for_capacity_timeout = "10m"

  enabled_metrics = [
      "GroupStandbyInstances",
      "GroupTotalInstances",
      "GroupPendingInstances",
      "GroupTerminatingInstances",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupMinSize",
      "GroupMaxSize"
  ]

  lifecycle {
    ignore_changes = ["force_delete",
      "metrics_granularity",
      "wait_for_capacity_timeout",
      "desired_capacity",
    ]
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "oregon-b.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "master-us-west-2b.masters.oregon-b.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-2b"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-oregon-a-moz-works" {
  desired_capacity          = 6
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "nodes.oregon-a.moz.works-20190920165600173700000002"
  max_size                  = 20
  min_size                  = 3
  metrics_granularity       = "1Minute"
  name                      = "nodes.oregon-a.moz.works"
  vpc_zone_identifier       = ["subnet-0d89cd37ecec22dd2"]
  wait_for_capacity_timeout = "10m"

  enabled_metrics = [
      "GroupStandbyInstances",
      "GroupTotalInstances",
      "GroupPendingInstances",
      "GroupTerminatingInstances",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupMinSize",
      "GroupMaxSize"
  ]

  lifecycle {
    ignore_changes = ["force_delete",
      "metrics_granularity",
      "wait_for_capacity_timeout",
      "desired_capacity",
    ]
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "oregon-a.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "nodes.oregon-a.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-oregon-b-moz-works" {
  desired_capacity          = 10
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "nodes.oregon-b.moz.works-20191001193310830700000002"
  max_size                  = 22
  min_size                  = 12
  metrics_granularity       = "1Minute"
  name                      = "nodes.oregon-b.moz.works"
  vpc_zone_identifier       = ["subnet-e290afaa"]
  wait_for_capacity_timeout = "10m"

  load_balancers = [
    "snippets-stage",
    "snippets-admin",
    "basket-stage",
    "bedrock-test",
    "snippets-dev",
    "snippets-prod",
    "basket-prod",
    "basket-dev",
    "basket-admin",
    "basket-prod-b",
    "basket-admin-stage"
  ]

  enabled_metrics = [
      "GroupStandbyInstances",
      "GroupTotalInstances",
      "GroupPendingInstances",
      "GroupTerminatingInstances",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupMinSize",
      "GroupMaxSize"
  ]


  lifecycle {
    ignore_changes = ["force_delete",
      "metrics_granularity",
      "wait_for_capacity_timeout",
      "desired_capacity",
    ]
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "oregon-b.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "nodes.oregon-b.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}
