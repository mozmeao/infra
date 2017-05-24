variable "region" {}

# general
variable "vpc_id" {}

# snippets ELB
variable "snippets_elb_name" {}

variable "snippets_subnets" {}

variable "snippets_http_listener_instance_port" {}

variable "snippets_https_listener_instance_port" {}

variable "snippets_ssl_cert_id" {}


# snippets-stats ELB
variable "snippets-stats_elb_name" {}

variable "snippets-stats_subnets" {}

variable "snippets-stats_http_listener_instance_port" {}

variable "snippets-stats_https_listener_instance_port" {}

variable "snippets-stats_ssl_cert_id" {}

# careers ELB
variable "careers_elb_name" {}

variable "careers_subnets" {}

variable "careers_http_listener_instance_port" {}

variable "careers_https_listener_instance_port" {}

variable "careers_ssl_cert_id" {}

# bedrock-stage ELB
variable "bedrock-stage_elb_name" {}

variable "bedrock-stage_subnets" {}

variable "bedrock-stage_http_listener_instance_port" {}

variable "bedrock-stage_https_listener_instance_port" {}

variable "bedrock-stage_ssl_cert_id" {}

# bedrock-prod ELB
variable "bedrock-prod_elb_name" {}

variable "bedrock-prod_subnets" {}

variable "bedrock-prod_http_listener_instance_port" {}

variable "bedrock-prod_https_listener_instance_port" {}

variable "bedrock-prod_ssl_cert_id" {}


# wilcard-allizom
variable "wildcard-allizom_elb_name" {}

variable "wildcard-allizom_subnets" {}

variable "wildcard-allizom_http_listener_instance_port" {}

variable "wildcard-allizom_https_listener_instance_port" {}

variable "wildcard-allizom_ssl_cert_id" {}


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
