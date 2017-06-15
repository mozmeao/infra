variable "fqdn" {}

variable "name" {}

variable "region" {}

resource "aws_route53_health_check" "health_check" {
  fqdn                    = "${var.fqdn}"
  port                    = 443
  type                    = "HTTPS"
  resource_path           = "/"
  failure_threshold       = "3"
  request_interval        = "30"
  cloudwatch_alarm_name   = ""
  cloudwatch_alarm_region = ""

  tags = {
    Name = "${var.name}"
  }
}

/*
# TODO: alarm_actions are per region :-(
        we'll need to create the sns action in ap-northeast-1 etc
resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name = "${var.name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "HealthCheckStatus"
  namespace = "AWS/Route53"
  period = "60"
  statistic = "Minimum"
  threshold = "3"
  alarm_actions = [
    "arn:aws:sns:us-east-1:236517346949:MozillaMarketingSlack",
    "arn:aws:sns:us-east-1:236517346949:eeaws"
  ]
  dimensions {
    HealthCheckId = "${aws_route53_health_check.health_check.id}"
  }
}
*/

