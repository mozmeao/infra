resource "aws_elb" "ac984662673b111e7b1e70287e8e34e8" {
  name                        = "ac984662673b111e7b1e70287e8e34e8"
  subnets                     = ["subnet-1349a175", "subnet-3c8c8e75"]
  security_groups             = ["sg-e8d05992"]
  cross_zone_load_balancing   = false
  idle_timeout                = 1200
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31600
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 30030
    instance_protocol  = "tcp"
    lb_port            = 9090
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 30001
    instance_protocol  = "tcp"
    lb_port            = 2222
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32105
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/9e22fa5e-3e54-4441-adf0-beb6fccaf0a4"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:31600"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"               = "deis/deis-router"
    "KubernetesCluster"                        = "portland.moz.works"
    "kubernetes.io/cluster/portland.moz.works" = "owned"
  }
}

resource "aws_elb" "ci-us-west-moz-works" {
  name                        = "ci-us-west-moz-works"
  subnets                     = ["subnet-505f3827", "subnet-536f2e36", "subnet-8f8931d6"]
  security_groups             = ["sg-bece53da"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  access_logs {
    bucket        = "ci-us-west-access-logs"
    bucket_prefix = "elb-logs"
    interval      = 5
  }

  listener {
    instance_port      = 4443
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/061c9881-4f2e-4022-a24d-fc05a15081f4"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 30
    target              = "TCP:80"
    timeout             = 5
  }

  tags {}
}

resource "aws_elb" "ad9c984f598bc11e7b1e70287e8e34e8" {
  name                        = "ad9c984f598bc11e7b1e70287e8e34e8"
  subnets                     = ["subnet-1349a175", "subnet-3c8c8e75"]
  security_groups             = ["sg-b426c1c9"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31761
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/ddf39755-b0e2-4bfa-92e5-7f2d6025db14"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:31761"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"               = "mdn-stage/web"
    "kubernetes.io/cluster/portland.moz.works" = "owned"
    "KubernetesCluster"                        = "portland.moz.works"
    "Stack"                                    = "MDN-stage"
  }
}

resource "aws_elb" "a8583e1be9a3711e7b1e70287e8e34e8" {
  name                        = "a8583e1be9a3711e7b1e70287e8e34e8"
  subnets                     = ["subnet-1349a175", "subnet-3c8c8e75"]
  security_groups             = ["sg-a9e00cd4"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31383
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/8b99db59-3310-402b-9266-2398e5733055"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:31383"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"               = "mdn-prod/web"
    "kubernetes.io/cluster/portland.moz.works" = "owned"
    "KubernetesCluster"                        = "portland.moz.works"
    "Stack"                                    = "MDN-prod"
  }
}

resource "aws_elb" "a59873061c36e11e7b1e70287e8e34e8" {
  name                        = "a59873061c36e11e7b1e70287e8e34e8"
  subnets                     = ["subnet-1349a175", "subnet-3c8c8e75"]
  security_groups             = ["sg-7b062806"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30987
    instance_protocol  = "tcp"
    lb_port            = 6503
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/921dce45-4537-4c2c-b4e4-0cc475e592ed"
  }

  listener {
    instance_port      = 32376
    instance_protocol  = "tcp"
    lb_port            = 6502
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 30966
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/921dce45-4537-4c2c-b4e4-0cc475e592ed"
  }

  listener {
    instance_port      = 32202
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:32202"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"               = "mdn-samples/mdn-samples-service"
    "KubernetesCluster"                        = "portland.moz.works"
    "kubernetes.io/cluster/portland.moz.works" = "owned"
  }
}

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
    instance_port      = 32418
    instance_protocol  = "tcp"
    lb_port            = 2222
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

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
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/a6377c2d-97e8-4d7b-bc43-0d6f41beb034"
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

resource "aws_elb" "bedrock-stage" {
  name                        = "bedrock-stage"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32743
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32318
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/657b1ca0-8c09-4add-90a2-1243470a6b45"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:32318/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "bedrock-stage"
  }
}

resource "aws_elb" "careers-stage" {
  name                        = "careers-stage"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31166
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31166
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/e3d6aa9a-0a9b-4fed-b2fa-d05ae0156677"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31166/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "careers-stage"
  }
}

resource "aws_elb" "a51544a9b133411e89b8402e6188a289" {
  name                        = "a51544a9b133411e89b8402e6188a289"
  subnets                     = ["subnet-0d89cd37ecec22dd2"]
  security_groups             = ["sg-072cb472eec3cfcf0"]
  cross_zone_load_balancing   = false
  idle_timeout                = 1200
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31901
    instance_protocol  = "tcp"
    lb_port            = 2222
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 32473
    instance_protocol  = "tcp"
    lb_port            = 9090
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31938
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31125
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/0a683933-3b11-4651-bf48-4fd8097d6b64"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:31938"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"               = "deis/deis-router"
    "KubernetesCluster"                        = "oregon-a.moz.works"
    "kubernetes.io/cluster/oregon-a.moz.works" = "owned"
  }
}

resource "aws_elb" "sumo-stage-a" {
  name                        = "sumo-stage-a"
  subnets                     = ["subnet-0d89cd37ecec22dd2"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30558
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 30558
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/eac90dfa-6796-40be-9eb5-eb522bd828ef"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:30558/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-a.moz.works"
    "Stack"             = "sumo-stage"
  }
}

resource "aws_elb" "sumo-prod-a" {
  name                        = "sumo-prod-a"
  subnets                     = ["subnet-0d89cd37ecec22dd2"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30139
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/976bd332-1fca-4ccb-bd99-9ce820c45d4f"
  }

  listener {
    instance_port      = 30139
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:30139/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-a.moz.works"
    "Stack"             = "sumo-prod"
  }
}

resource "aws_elb" "sumo-stage-b" {
  name                        = "sumo-stage-b"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31129
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/eac90dfa-6796-40be-9eb5-eb522bd828ef"
  }

  listener {
    instance_port      = 31129
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31129/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "sumo-stage"
  }
}

resource "aws_elb" "sumo-prod-b" {
  name                        = "sumo-prod-b"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30139
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 30139
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/976bd332-1fca-4ccb-bd99-9ce820c45d4f"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:30139/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "sumo-prod"
  }
}

resource "aws_elb" "sumo-prod" {
  name                        = "sumo-prod"
  subnets                     = ["subnet-0d89cd37ecec22dd2", "subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30139
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 30139
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/a047ca5c-b1b1-40e8-9dff-28846d1d5032"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:30139/healthz/"
    timeout             = 5
  }

  tags {
    "Stack" = "SUMO-prod"
  }
}


# "high level" SUMO ELB cipher suites
# w/ Windows XP support
module "sumo-stage-a-policy" {
    source = "./sumo-policy"
    name = "sumo-stage-a-policy"
    load_balancer="${aws_elb.sumo-stage-a.id}"
    lb_port = 443
}

module "sumo-stage-b-policy" {
    source = "./sumo-policy"
    name = "sumo-stage-b-policy"
    load_balancer="${aws_elb.sumo-stage-b.id}"
    lb_port = 443
}


module "sumo-prod-policy" {
    source = "./sumo-policy"
    name = "sumo-prod-policy"
    load_balancer="${aws_elb.sumo-prod.id}"
    lb_port = 443
}


module "sumo-prod-a-policy" {
    source = "./sumo-policy"
    name = "sumo-prod-a-policy"
    load_balancer="${aws_elb.sumo-prod-a.id}"
    lb_port = 443
}


module "sumo-prod-b-policy" {
    source = "./sumo-policy"
    name = "sumo-prod-b-policy"
    load_balancer="${aws_elb.sumo-prod-b.id}"
    lb_port = 443
}

resource "aws_elb" "bedrock-prod" {
  name                        = "bedrock-prod"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 30024
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::236517346949:server-certificate/www.mozilla.org"
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
    target              = "HTTP:30024/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "bedrock-prod"
  }
}

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
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/6b9ebb9d-144a-474d-812f-56acc5101c56"
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

resource "aws_elb" "snippets-stats-b" {
  name                        = "snippets-stats-b"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31451
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31451
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/8dce3494-a641-4301-b707-5920c9aabf49"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31451/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "snippets-stats"
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
}

resource "aws_elb" "careers-prod" {
  name                        = "careers-prod"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31898
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  listener {
    instance_port      = 31898
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/ae2d2e64-b345-4bc1-a49a-5860c73a0809"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "HTTP:31898/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "careers-prod"
  }
}

resource "aws_elb" "basket-dev" {
  name                        = "basket-dev"
  subnets                     = ["subnet-e290afaa"]
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

resource "aws_elb" "a26612beb807111e88eeb0656fabf84c" {
  name                        = "a26612beb807111e88eeb0656fabf84c"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-0c63c5b576e33efa9"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 32493
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "ssl"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/a6377c2d-97e8-4d7b-bc43-0d6f41beb034"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 10
    target              = "TCP:32493"
    timeout             = 5
  }

  tags {
    "kubernetes.io/service-name"               = "bedrock-demo/voyager-bedrock-demo-ingress"
    "kubernetes.io/cluster/oregon-b.moz.works" = "owned"
    "KubernetesCluster"                        = "oregon-b.moz.works"
  }
}

resource "aws_elb" "bedrock-dev" {
  name                        = "bedrock-dev"
  subnets                     = ["subnet-e290afaa"]
  security_groups             = ["sg-44858b38"]
  cross_zone_load_balancing   = false
  idle_timeout                = 120
  connection_draining         = false
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port      = 31467
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:236517346949:certificate/21a09f64-2eb3-438c-b6d2-080b07df93d4"
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
    target              = "HTTP:31467/healthz/"
    timeout             = 5
  }

  tags {
    "KubernetesCluster" = "oregon-b.moz.works"
    "Stack"             = "bedrock-dev"
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
