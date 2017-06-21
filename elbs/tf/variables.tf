variable "region" {}

# general
variable "vpc_id" {}

# security group id of group named "elb_access"
variable "elb_access_id" {}

# snippets ELB
variable "snippets_elb_name" {}

variable "snippets_subnets" {}

variable "snippets_http_listener_instance_port" {}

variable "snippets_https_listener_instance_port" {}

variable "snippets_ssl_cert_id" {}

variable "snippets-elbs-by-region" {
  type = "map"
  default = {
    "ap-northeast-1" = true
    "eu-central-1" = true
    "us-east-1" = true
  }
}

# snippets-stats ELB
variable "snippets-stats_elb_name" {}

variable "snippets-stats_subnets" {}

variable "snippets-stats_http_listener_instance_port" {}

variable "snippets-stats_https_listener_instance_port" {}

variable "snippets-stats_ssl_cert_id" {}

variable "snippets-stats-elbs-by-region" {
  type = "map"
  default = {
    "ap-northeast-1" = true
    "us-east-1" = true
  }
}

# careers ELB
variable "careers_elb_name" {}

variable "careers_subnets" {}

variable "careers_http_listener_instance_port" {}

variable "careers_https_listener_instance_port" {}

variable "careers_ssl_cert_id" {}

variable "careers-elbs-by-region" {
  type = "map"
  default = {
    "ap-northeast-1" = true
    "eu-central-1" = true
    "us-east-1" = true
  }
}


# bedrock-stage ELB
variable "bedrock-stage_elb_name" {}

variable "bedrock-stage_subnets" {}

variable "bedrock-stage_http_listener_instance_port" {}

variable "bedrock-stage_https_listener_instance_port" {}

variable "bedrock-stage_ssl_cert_id" {}

variable "bedrock-stage-elbs-by-region" {
  type = "map"
  default = {
    "ap-northeast-1" = true
    "eu-central-1" = true
    "us-east-1" = true
  }
}

# bedrock-prod ELB
variable "bedrock-prod_elb_name" {}

variable "bedrock-prod_subnets" {}

variable "bedrock-prod_http_listener_instance_port" {}

variable "bedrock-prod_https_listener_instance_port" {}

variable "bedrock-prod_ssl_cert_id" {}

variable "bedrock-prod-elbs-by-region" {
  type = "map"
  default = {
    "ap-northeast-1" = true
    "eu-central-1" = true
    "us-east-1" = true
  }
}

# wilcard-allizom
variable "wildcard-allizom_elb_name" {}

variable "wildcard-allizom_subnets" {}

variable "wildcard-allizom_http_listener_instance_port" {}

variable "wildcard-allizom_https_listener_instance_port" {}

variable "wildcard-allizom_ssl_cert_id" {}

variable "wildcard-allizom-elbs-by-region" {
  type = "map"
  default = {
    "us-east-1" = true
  }
}


# nucleus-prod ELB
variable "nucleus-prod_elb_name" {}

variable "nucleus-prod_subnets" {}

variable "nucleus-prod_http_listener_instance_port" {}

variable "nucleus-prod_https_listener_instance_port" {}

variable "nucleus-prod_ssl_cert_id" {}

variable "nucleus-elbs-by-region" {
  type = "map"
  default = {
    "us-east-1" = true
  }
}


# surveillance
variable "surveillance-prod_elb_name" {}

variable "surveillance-prod_subnets" {}

variable "surveillance-prod_http_listener_instance_port" {}

variable "surveillance-prod_https_listener_instance_port" {}

variable "surveillance-prod_ssl_cert_id" {}

variable "surveillance-elbs-by-region" {
  type = "map"
  default = {
    "us-east-1" = true
  }
}

# basket-stage ELB
variable "basket-stage_elb_name" {}

variable "basket-stage_subnets" {}

variable "basket-stage_http_listener_instance_port" {}

variable "basket-stage_https_listener_instance_port" {}

variable "basket-stage_ssl_cert_id" {}

variable "basket-stage-elbs-by-region" {
  type = "map"
  default = {
    "ap-northeast-1" = true
    "eu-central-1" = true
    "us-east-1" = true
  }
}


# basket-prod ELB
variable "basket-prod_elb_name" {}

variable "basket-prod_subnets" {}

variable "basket-prod_http_listener_instance_port" {}

variable "basket-prod_https_listener_instance_port" {}

variable "basket-prod_ssl_cert_id" {}

variable "basket-prod-elbs-by-region" {
  type = "map"
  default = {
    "ap-northeast-1" = true
    "eu-central-1" = true
    "us-east-1" = true
  }
}

