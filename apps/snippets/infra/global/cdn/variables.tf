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

variable "default_cache_target_origin_id" {}

variable "ordered_cache_target_origin_id" {}

variable "origin_domain_name" {}