provider "aws" {
  region = "${var.region}"
}



resource "aws_elasticache_cluster" "mdn-redis" {
    cluster_id = "mdn-redis"
    engine = "redis"
    node_type = "${var.cache-node-size}"
    port = "${var.cache-port}"
    num_cache_nodes = "${var.cache-num-nodes}"
    parameter_group_name = "${var.cache-param-group}"
}

resource "aws_elasticsearch_domain" "mdn-elasticsearch" {
  domain_name           = "mdn-elasticsearch"
  elasticsearch_version = "${var.es-version}"

  cluster_config {
    instance_type  = "${var.es-instance-type}"
    instance_count = "${var.es-instance-count}"
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "${var.es-ebs-volume-type}"
    volume_size = "${var.es-ebs-volume-size}"
  }

  #advanced_options {
  #    "rest.action.multi.allow_explicit_index" = true
  #}

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
             "Resource": ["arn:aws:ec2:${var.region}:*:mdn-elasticsearch-access/*"]
        }
    ]
}
CONFIG
  snapshot_options {
    automated_snapshot_start_hour = "${var.es-snapshot-hour}"
  }
  tags {
    Domain = "mdn-elasticsearch"
  }
}


resource "aws_security_group" "mdn-elasticsearch-access" {
  name = "mdn-elasticsearch-access"
  description = "SG for ElasticSearch"

  ingress {
      from_port = 0
      to_port = 9200
      protocol = "tcp"
      security_groups = "${var.es_security_groups}"
  }

  ingress {
      from_port = 0
      to_port = 9300
      protocol = "tcp"
      security_groups = "${var.es_security_groups}"
  }
}
