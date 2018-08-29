resource "aws_elb" "a63990d51037511e7845b06353bb5962" {
    name                        = "a63990d51037511e7845b06353bb5962"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-cf763da8"]
    instances                   = ["i-0ca9420ae5bebeb96", "i-0c944b2b4374ebfa8", "i-0604100b13b62ea41", "i-0c8865eb6a008eac2", "i-0d4362cbbf4d8eaab"]
    cross_zone_load_balancing   = false
    idle_timeout                = 1200
    connection_draining         = false
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 32560
        instance_protocol  = "tcp"
        lb_port            = 2222
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port      = 30150
        instance_protocol  = "tcp"
        lb_port            = 80
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port      = 31986
        instance_protocol  = "tcp"
        lb_port            = 9090
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port      = 31882
        instance_protocol  = "tcp"
        lb_port            = 443
        lb_protocol        = "ssl"
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/a2a637ae-52bf-421d-bc95-6aa20eda649f"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "TCP:30150"
        timeout             = 5
    }

    tags {
        "kubernetes.io/service-name" = "deis/deis-router"
        "KubernetesCluster" = "tokyo.moz.works"
    }
}

resource "aws_elb" "snippets" {
    name                        = "snippets"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-ac070bcb"]
    instances                   = ["i-0604100b13b62ea41", "i-0ca9420ae5bebeb96", "i-0d4362cbbf4d8eaab", "i-0c8865eb6a008eac2", "i-0c944b2b4374ebfa8"]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 30518
        instance_protocol  = "tcp"
        lb_port            = 80
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port      = 32420
        instance_protocol  = "tcp"
        lb_port            = 443
        lb_protocol        = "ssl"
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/88d7cda5-e9cb-4866-964f-d0cf4dcc32be"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "HTTP:32420/healthz/"
        timeout             = 5
    }

    tags {
    }
}

resource "aws_elb" "careers" {
    name                        = "careers"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-ac070bcb"]
    instances                   = ["i-0604100b13b62ea41", "i-0ca9420ae5bebeb96", "i-0d4362cbbf4d8eaab", "i-0c944b2b4374ebfa8", "i-0c8865eb6a008eac2"]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 30518
        instance_protocol  = "tcp"
        lb_port            = 80
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port      = 30418
        instance_protocol  = "tcp"
        lb_port            = 443
        lb_protocol        = "ssl"
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/1063b46f-9755-47a1-9c26-ede6c66d810d"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "HTTP:30418/healthz/"
        timeout             = 5
    }

    tags {
    }
}

resource "aws_elb" "snippets-stats" {
    name                        = "snippets-stats"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-ac070bcb"]
    instances                   = ["i-0ca9420ae5bebeb96", "i-0d4362cbbf4d8eaab", "i-0c8865eb6a008eac2", "i-0604100b13b62ea41", "i-0c944b2b4374ebfa8"]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 30518
        instance_protocol  = "tcp"
        lb_port            = 80
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port      = 30183
        instance_protocol  = "tcp"
        lb_port            = 443
        lb_protocol        = "ssl"
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/3fd8337d-9476-46a9-acda-47abc3b95472"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "HTTP:30183/"
        timeout             = 5
    }

    tags {
    }
}

resource "aws_elb" "a09c0082826ea11e7845b06353bb5962" {
    name                        = "a09c0082826ea11e7845b06353bb5962"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-2bbcaa4c"]
    instances                   = ["i-0ca9420ae5bebeb96", "i-0c8865eb6a008eac2", "i-0604100b13b62ea41", "i-0c944b2b4374ebfa8", "i-0d4362cbbf4d8eaab"]
    cross_zone_load_balancing   = false
    idle_timeout                = 60
    connection_draining         = false
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 30420
        instance_protocol  = "tcp"
        lb_port            = 80
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "TCP:30420"
        timeout             = 5
    }

    tags {
        "kubernetes.io/service-name" = "mdn-dev/web"
        "KubernetesCluster" = "tokyo.moz.works"
    }
}

resource "aws_elb" "bedrock-stage" {
    name                        = "bedrock-stage"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-ac070bcb"]
    instances                   = ["i-0604100b13b62ea41", "i-0ca9420ae5bebeb96", "i-0d4362cbbf4d8eaab", "i-0c8865eb6a008eac2", "i-0c944b2b4374ebfa8"]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 31328
        instance_protocol  = "http"
        lb_port            = 443
        lb_protocol        = "https"
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/a2a637ae-52bf-421d-bc95-6aa20eda649f"
    }

    listener {
        instance_port      = 31328
        instance_protocol  = "http"
        lb_port            = 80
        lb_protocol        = "http"
        ssl_certificate_id = ""
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "HTTP:31328/healthz/"
        timeout             = 5
    }

    tags {
    }
}

resource "aws_elb" "bedrock-prod" {
    name                        = "bedrock-prod"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-ac070bcb"]
    instances                   = ["i-0ca9420ae5bebeb96", "i-0d4362cbbf4d8eaab", "i-0c944b2b4374ebfa8", "i-0604100b13b62ea41", "i-0c8865eb6a008eac2"]
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
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/099d5838-a413-478a-abc1-afb67c4017f1"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "HTTP:32249/healthz/"
        timeout             = 5
    }

    tags {
    }
}

resource "aws_elb" "basket-stage" {
    name                        = "basket-stage"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-ac070bcb"]
    instances                   = ["i-0ca9420ae5bebeb96", "i-0604100b13b62ea41", "i-0d4362cbbf4d8eaab", "i-0c944b2b4374ebfa8", "i-0c8865eb6a008eac2"]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 30518
        instance_protocol  = "tcp"
        lb_port            = 80
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port      = 30326
        instance_protocol  = "tcp"
        lb_port            = 443
        lb_protocol        = "ssl"
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/f2f3eb0a-c9c9-4404-b89d-16d3e47b8bcc"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "HTTP:30326/healthz/"
        timeout             = 5
    }

    tags {
    }
}

resource "aws_elb" "basket-prod" {
    name                        = "basket-prod"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-ac070bcb"]
    instances                   = ["i-0604100b13b62ea41", "i-0ca9420ae5bebeb96", "i-0d4362cbbf4d8eaab", "i-0c944b2b4374ebfa8", "i-0c8865eb6a008eac2"]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 30518
        instance_protocol  = "tcp"
        lb_port            = 80
        lb_protocol        = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port      = 32621
        instance_protocol  = "tcp"
        lb_port            = 443
        lb_protocol        = "ssl"
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/9c13521f-c93e-42f0-b969-b11fd571ff91"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "HTTP:32621/healthz/"
        timeout             = 5
    }

    tags {
    }
}

resource "aws_elb" "bedrock-dev" {
    name                        = "bedrock-dev"
    subnets                     = ["subnet-ed79369b"]
    security_groups             = ["sg-0c1baaaf9d1f992cd"]
    instances                   = ["i-0c8865eb6a008eac2", "i-0c944b2b4374ebfa8", "i-0604100b13b62ea41", "i-0ca9420ae5bebeb96", "i-0d4362cbbf4d8eaab"]
    cross_zone_load_balancing   = false
    idle_timeout                = 60
    connection_draining         = false
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 31207
        instance_protocol  = "http"
        lb_port            = 443
        lb_protocol        = "https"
        ssl_certificate_id = "arn:aws:acm:ap-northeast-1:236517346949:certificate/d01eb107-6e73-4781-9736-a6897e3468c9"
    }

    listener {
        instance_port      = 31207
        instance_protocol  = "http"
        lb_port            = 80
        lb_protocol        = "http"
        ssl_certificate_id = ""
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 6
        interval            = 10
        target              = "HTTP:31207/healthz/"
        timeout             = 5
    }

    tags {
        "KubernetesCluster" = "tokyo.moz.works"
        "Stack" = "bedrock-dev"
    }
}

