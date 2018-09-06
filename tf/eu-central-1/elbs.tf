resource "aws_elb" "a82511f724fb611e78dc902859405480" {
  name                        = "a82511f724fb611e78dc902859405480"
  subnets                     = ["subnet-10685f78"]
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
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/eac03015-d53b-42f2-84e9-2b58a0231e8b"
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
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/fa2169bd-cd78-4024-adf2-659424de6b45"
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

resource "aws_elb" "careers" {
  name                        = "careers"
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
    instance_port      = 32563
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/4f35a95e-1e27-4402-94f6-2d6ff49ea7a0"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32563/healthz/"
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

resource "aws_elb" "bedrock-stage" {
  name                        = "bedrock-stage"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31328
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31328
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/79885752-992b-48a4-8170-22475cac599e"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31328/healthz/"
    timeout             = 5
  }

  tags {}
}

resource "aws_elb" "snippets-stats" {
  name                        = "snippets-stats"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31024
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/290a91d7-4f69-4791-b670-534b671bd6b8"
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
    target              = "HTTP:31024/"
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
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/9a38de62-3461-43a4-9027-4ec5d165e0d6"
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

resource "aws_elb" "a37e4a92db2a611e78dc902859405480" {
  name                        = "a37e4a92db2a611e78dc902859405480"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-46b6642c"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31616
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/cf35a587-76f9-44be-8220-66899cf945fc"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:31616"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"                = "mdn-prod/web"
    "KubernetesCluster"                         = "frankfurt.moz.works"
    "kubernetes.io/cluster/frankfurt.moz.works" = "owned"
  }
}

resource "aws_elb" "aebf2210abda911e78dc902859405480" {
  name                        = "aebf2210abda911e78dc902859405480"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-82c16be8"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30107
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:30107"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"                = "openvpn/yummy-armadillo-openvpn"
    "KubernetesCluster"                         = "frankfurt.moz.works"
    "kubernetes.io/cluster/frankfurt.moz.works" = "owned"
  }
}

resource "aws_elb" "sumo-dev" {
  name                        = "sumo-dev"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31983
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31983
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/6bf2d490-690a-476e-992b-c9ad73488d2f"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31983/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "frankfurt.moz.works"
    "Stack"             = "sumo-dev"
  }
}

resource "aws_elb" "sumo-stage" {
  name                        = "sumo-stage"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31076
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31076
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/b74e73f7-6fd7-4fea-99fa-c67e34556077"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31076/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "frankfurt.moz.works"
    "Stack"             = "sumo-stage"
  }
}

resource "aws_elb" "sumo-prod" {
  name                        = "sumo-prod"
  subnets                     = ["subnet-10685f78"]
  security_groups             = ["sg-02552a69"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32502
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:eu-central-1:236517346949:certificate/88ff1ddb-7a2f-4a78-85b3-cdcc0ea97124"
  }

  listener {
    instance_port      = 32502
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32502/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "frankfurt.moz.works"
    "Stack"             = "sumo-prod"
  }
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
