resource "aws_autoscaling_group" "master-us-west-2a-masters-oregon-a-moz-works" {
  desired_capacity          = 1
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "master-us-west-2a.masters.oregon-a.moz.works-00ee8d519143a65e3c27f5a21a"
  max_size                  = 1
  min_size                  = 1
  metrics_granularity       = "1Minute"
  name                      = "master-us-west-2a.masters.oregon-a.moz.works"
  vpc_zone_identifier       = ["subnet-0d89cd37ecec22dd2"]
  wait_for_capacity_timeout = "10m"

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

resource "aws_autoscaling_group" "master-us-west-2a-masters-portland-moz-works" {
  desired_capacity          = 1
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "master-us-west-2a.masters.portland.moz.works-005227c0a7484076e643d78552"
  max_size                  = 1
  min_size                  = 1
  metrics_granularity       = "1Minute"
  name                      = "master-us-west-2a.masters.portland.moz.works"
  vpc_zone_identifier       = ["subnet-1349a175"]
  wait_for_capacity_timeout = "10m"

  lifecycle {
    ignore_changes = ["force_delete",
      "metrics_granularity",
      "wait_for_capacity_timeout",
      "desired_capacity",
    ]
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "portland.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "master-us-west-2a.masters.portland.moz.works"
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
  launch_configuration      = "master-us-west-2b.masters.oregon-b.moz.works-0070023b5c9242310476f7d37b"
  max_size                  = 1
  min_size                  = 1
  metrics_granularity       = "1Minute"
  name                      = "master-us-west-2b.masters.oregon-b.moz.works"
  vpc_zone_identifier       = ["subnet-e290afaa"]
  wait_for_capacity_timeout = "10m"

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
  launch_configuration      = "nodes.oregon-a.moz.works-00ee8d519143a65e3c27f5a21b"
  max_size                  = 20
  min_size                  = 2
  metrics_granularity       = "1Minute"
  name                      = "nodes.oregon-a.moz.works"
  vpc_zone_identifier       = ["subnet-0d89cd37ecec22dd2"]
  wait_for_capacity_timeout = "10m"

  load_balancers = [
    "sumo-prod-a",
    "sumo-stage-a",
    "sumo-prod",
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
  launch_configuration      = "nodes.oregon-b.moz.works-0070023b5c9242310476f7d37a"
  max_size                  = 20
  min_size                  = 2
  metrics_granularity       = "1Minute"
  name                      = "nodes.oregon-b.moz.works"
  vpc_zone_identifier       = ["subnet-e290afaa"]
  wait_for_capacity_timeout = "10m"

  load_balancers = [
    "snippets-stage",
    "snippets-admin",
    "sumo-prod",
    "basket-stage",
    "bedrock-prod",
    "snippets-dev",
    "bedrock-dev",
    "snippets-prod",
    "basket-prod",
    "snippets-stats-b",
    "bedrock-stage",
    "basket-dev",
    "sumo-prod-b",
    "basket-admin",
    "basket-prod-b",
    "careers-stage",
    "sumo-stage-b",
    "careers-prod",
    "basket-admin-stage",
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

resource "aws_autoscaling_group" "nodes-portland-moz-works" {
  desired_capacity          = 10
  force_delete              = false
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "nodes.portland.moz.works-005227c0a7484076e643d78551"
  max_size                  = 15
  min_size                  = 10
  metrics_granularity       = "1Minute"
  name                      = "nodes.portland.moz.works"
  vpc_zone_identifier       = ["subnet-1349a175"]
  wait_for_capacity_timeout = "10m"

  lifecycle {
    ignore_changes = ["force_delete",
      "metrics_granularity",
      "wait_for_capacity_timeout",
      "desired_capacity",
    ]
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "portland.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "nodes.portland.moz.works"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}
