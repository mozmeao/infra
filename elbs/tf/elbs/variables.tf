variable "elb_name" {}

variable "security_group_id" {}

variable "http_listener_instance_port" {}

variable "http_listener_elb_protocol" {
  default = "TCP"
}

variable "http_listener_instance_protocol" {
  default = "TCP"
}

variable "https_listener_instance_port" {}

variable "https_listener_elb_protocol" {
  default = "SSL"
}

variable "https_listener_instance_protocol" {
  default = "TCP"
}

variable "ssl_cert_id" {}

variable "idle_timeout" {
  default = 60
}

variable "connection_draining_enabled" {
  default = "true"
}

variable "connection_draining_timeout" {
  default = 300
}

variable "subnets" {}
