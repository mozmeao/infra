variable "region" {
  default = "us-west-2"
}

variable "enabled" {
  default = true
}

variable "aliases" {
  type = "list"
}

variable "comment" {}

variable "environment" {}

variable "certificate_arn" {}

variable "log_bucket" {}

variable "log_prefix" {}
