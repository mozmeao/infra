variable enabled {
  default = true
}

variable region {
  default = "us-west-2"
}

variable environment {}

variable features {
  default = {
    shared-infra = 1
    cdn          = 1
    efs          = 1
    rds          = 1
    redis        = 1
    memcached    = 1
  }
}

variable cloudfront_primary {
  default = {
    enabled           = "1"
    distribution_name = "mdn-primary-cdn"
    aliases.stage     = "developer.mdn.mozit.cloud"
    aliases.prod      = "developer-prod.mdn.mozit.cloud"
    domain.stage      = "stage.mdn.mozit.cloud"
    domain.prod       = "prod.mdn.mozit.cloud"
  }
}

variable cloudfront_attachments {
  default = {
    enabled           = "1"
    distribution_name = "mdn-attachment-cdn"
    aliases.stage     = ""
    aliases.prod      = "mdn.mozillademos.org,mdn-demos.moz.works"
    acm_arn.stage     = ""
    acm_arn.prod      = "arn:aws:acm:us-west-2:178589013767:certificate/2f399635-126c-4e83-bf43-5ddbd0525719"
    domain.stage      = ""
    domain.prod       = "mdn-demos-origin.moz.works"
  }
}
