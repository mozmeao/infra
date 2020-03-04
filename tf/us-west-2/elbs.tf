

resource "aws_elb" "abb45ebd7fbb211e788530656fabf84c" {
  name                        = "abb45ebd7fbb211e788530656fabf84c"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-d4676ea8"]
  cross_zone_load_balancing   = false
  idle_timeout                = 1200
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32413
    instance_protocol  = "tcp"
    lb_port            = 9090
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31094
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32530
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/3865bd6b-c6e2-4c8b-b68d-45cf7ef0b455"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:31094"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"               = "deis/deis-router"
    "kubernetes.io/cluster/oregon-b.moz.works" = "owned"
    "KubernetesCluster"                        = "oregon-b.moz.works"
  }
}

resource "aws_elb" "snippets-stage" {
  name                        = "snippets-stage"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30586
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/6c8ca0be-8082-4587-9f19-42db2603d593"
  }

  listener {
    instance_port      = 30586
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:30586/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "snippets-stage"
  }
}

# resource "aws_elb" "a51544a9b133411e89b8402e6188a289" {
#   name                        = "a51544a9b133411e89b8402e6188a289"
#   subnets                     = ["subnet-0d89cd37ecec22dd2"]
#   security_groups             = ["sg-072cb472eec3cfcf0"]
#   cross_zone_load_balancing   = false
#   idle_timeout                = 1200
#   connection_draining         = false
#   connection_draining_timeout = 300
#   internal                    = false

#   listener {
#     instance_port      = 31901
#     instance_protocol  = "tcp"
#     lb_port            = 2222
#     lb_protocol        = "tcp"
#     ssl_certificate_id = ""
#   }

#   listener {
#     instance_port      = 32473
#     instance_protocol  = "tcp"
#     lb_port            = 9090
#     lb_protocol        = "tcp"
#     ssl_certificate_id = ""
#   }

#   listener {
#     instance_port      = 31938
#     instance_protocol  = "tcp"
#     lb_port            = 80
#     lb_protocol        = "tcp"
#     ssl_certificate_id = ""
#   }

#   listener {
#     instance_port      = 31125
#     instance_protocol  = "tcp"
#     lb_port            = 443
#     lb_protocol        = "ssl"
#     ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/0a683933-3b11-4651-bf48-4fd8097d6b64"
#   }

#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 6
#     interval            = 10
#     target              = "TCP:31938"
#     timeout             = 5
#   }

#   tags {
#     "kubernetes.io/service-name"               = "deis/deis-router"
#     "KubernetesCluster"                        = "oregon-a.moz.works"
#     "kubernetes.io/cluster/oregon-a.moz.works" = "owned"
#   }
# }

resource "aws_elb" "basket-prod-b" {
  name                        = "basket-prod-b"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32162
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/ce86f1b1-7020-432f-9f79-b05c1e301d8e"
  }

  listener {
    instance_port      = 32162
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32162/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "basket-prod"
  }
}

resource "aws_elb" "snippets-prod" {
  name                        = "snippets-prod"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32423
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32423
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/5514f163-47e2-4a2c-afe1-4af5d3bdb7f9"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32423/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "snippets-prod"
  }
}

resource "aws_elb" "snippets-admin" {
  name                        = "snippets-admin"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31204
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31204
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/95897544-d03f-496c-9b60-9c20be4e0696"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31204/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "snippets-admin"
  }

  access_logs {
    bucket        = "mozmeao-elb-access-logs-us-west-2"
    interval      = 15
  }

}


resource "aws_elb" "basket-dev" {
  name                        = "basket-dev"
  subnets                     = ["subnet-e290afaa","subnet-0d89cd37ecec22dd2"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31107
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31107
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/5b7b7e99-dd57-4bce-92ea-c1a2534340bb"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31107/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "basket-dev"
  }
}

resource "aws_elb" "basket-stage" {
  name                        = "basket-stage"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32389
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32389
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/8470c4e1-2acd-4e6e-b5e8-9e9560caa2c0"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32389/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "basket-stage"
  }
}

resource "aws_elb" "basket-admin-stage" {
  name                        = "basket-admin-stage"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31906
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31906
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/8470c4e1-2acd-4e6e-b5e8-9e9560caa2c0"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31906/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "basket-admin-stage"
  }
}

resource "aws_elb" "basket-prod" {
  name                        = "basket-prod"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32162
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32162
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/ce86f1b1-7020-432f-9f79-b05c1e301d8e"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32162/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "basket-prod"
  }
}

resource "aws_elb" "basket-admin" {
  name                        = "basket-admin"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31973
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31973
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/a6ddbe25-f5a0-4c2e-aa7f-02c328e30526"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31973/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "basket-admin"
  }
}

resource "aws_elb" "bedrock-test" {
  name                        = "bedrock-test"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31888
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/1f05b4cd-09ff-423b-8443-2567eab6c7e4"
  }

  listener {
    instance_port      = 32743
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31888/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "bedrock-test"
  }
}

resource "aws_elb" "snippets-dev" {
  name                        = "snippets-dev"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30098
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 30098
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/34e80874-09dd-4baa-b544-72d0aa630794"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:30098/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "snippets-dev"
  }
}
