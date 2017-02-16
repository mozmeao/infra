variable "region" {
  default = "us-east-1"
}

##### Redis
variable "cache-node-size" {
  default = "cache.t2.micro"
}

variable "cache-port" {
  default = "6379"
}

variable "cache-num-nodes" {
  default = "1"
}

variable "cache-param-group" {
  default = "default.redis3.2"
}

##### Elasticsearch
variable "es-version" {
  default = "5.1"
}

variable "es-source-ip" {
  default = ["192.168.1.2/32"]
}

# 24-hour format, not sure which tz it's based on
variable "es-snapshot-hour" {
  default = 23
}

variable "es-instance-type" {
  default = "m3.medium.elasticsearch"
}

variable "es-instance-count" {
  default = 3
}

variable "es-ebs-volume-type" {
  default = "gp2"
}

# specified in GiBs
variable "es-ebs-volume-size" {
  default = "10"
}
