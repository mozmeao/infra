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
    aliases.stage     = "developer-stage.mdn.mozit.cloud"
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
    aliases.prod      = "mdn.mozillademos.org,demos.mdn.mozit.cloud"
    acm_arn.stage     = ""
    acm_arn.prod      = "arn:aws:acm:us-west-2:178589013767:certificate/2f399635-126c-4e83-bf43-5ddbd0525719"
    domain.stage      = ""
    domain.prod       = "prod.mdn.mozit.cloud"
  }
}

variable memcached {
  default = {
    node_size.stage = "cache.t2.small"
    node_size.prod  = "cache.m3.xlarge"
    num_nodes.stage = "3"
    num_nodes.prod  = "3"
  }
}

variable redis {
  default = {
    node_size.stage = "cache.t2.small"
    node_size.prod  = "cache.m3.xlarge"
    num_nodes.stage = "3"
    num_nodes.prod  = "3"
  }
}

variable rds {
  default = {
    db_name.stage               = "developer_allizom_org"
    db_name.prod                = "developer_mozilla_org"
    username.stage              = "root"
    username.prod               = "root"
    password.stage              = ""
    password.prod               = ""
    instance_class.stage        = "db.t2.large"
    instance_class.prod         = "db.m4.xlarge"
    backup_retention_days.stage = "0"
    backup_retention_days.prod  = "7"
    storage_gb.stage            = "100"
    storage_gb.prod             = "200"
    storage_type                = "gp2"
  }
}
