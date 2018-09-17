variable "region" {
  default = "us-west-2"
}

variable enabled {}

variable environment {}

variable cloudfront_primary_enabled {}

variable cloudfront_primary_aliases {
  type = "list"
}

variable cloudfront_primary_distribution_name {
  default = "mdn-primary-cdn"
}

variable acm_primary_cert_arn {}

variable cloudfront_primary_domain_name {}

variable cloudfront_attachments_enabled {}

variable cloudfront_attachments_aliases {
  type = "list"
}

variable cloudfront_attachments_distribution_name {
  default = "mdn-attachments-cdn"
}

variable cloudfront_attachments_domain_name {}

variable acm_attachments_cert_arn {}
