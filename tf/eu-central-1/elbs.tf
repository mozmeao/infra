resource "aws_elb" "a82511f724fb611e78dc902859405480" {
  name                        = "a82511f724fb611e78dc902859405480"
  subnets                     = ["subnet-10685f78","subnet-57ef9f2d"]
  security_groups             = ["sg-8d1064e6"]
  cross_zone_load_balancing   = false
  idle_timeout                = 1200
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31670
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/79885752-992b-48a4-8170-22475cac599e"
  }

  listener {
    instance_port      = 32208
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32033
    instance_protocol  = "tcp"
    lb_port            = 9090
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32480
    instance_protocol  = "tcp"
    lb_port            = 2222
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:32208"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"                = "deis/deis-router"
    "KubernetesCluster"                         = "frankfurt.moz.works"
    "kubernetes.io/cluster/frankfurt.moz.works" = "owned"
  }
}

resource "aws_elb" "basket-prod" {
  name                        = "basket-prod"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31441
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31305
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/d6d41a56-17fd-4588-bd32-cdd1c4174ec8"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31305/healthz/"
    timeout             = 5
  }

  tags {}
}

resource "aws_elb" "basket-stage" {
  name                        = "basket-stage"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31441
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32692
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/0c02d92c-c9cd-4e51-b397-ed49bb851a66"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32692/healthz/"
    timeout             = 5
  }

  tags {}
}

resource "aws_elb" "snippets" {
  name                        = "snippets"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31441
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31584
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/148dc9eb-d026-4c09-89db-41bafd3f2077"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31584/healthz/"
    timeout             = 5
  }

  tags {}
}

resource "aws_elb" "bedrock-prod" {
  name                        = "bedrock-prod"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32249
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32249
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/79885752-992b-48a4-8170-22475cac599e"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32249/healthz/"
    timeout             = 5
  }

  tags {}
}

resource "aws_elb" "nucleus-prod" {
  name                        = "nucleus-prod"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31758
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/73da790d-5c41-47c5-b032-fd65674804ee"
  }

  listener {
    instance_port      = 31441
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31758/"
    timeout             = 5
  }

  tags {}
}

resource "aws_elb" "bedrock-dev" {
  name                        = "bedrock-dev"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31441
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31207
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/802eee09-7361-4de1-84c3-9704d85b1e2b"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31207/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "frankfurt.moz.works"
    "Stack"             = "bedrock-dev"
  }
}
