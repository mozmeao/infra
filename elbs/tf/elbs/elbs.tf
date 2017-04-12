resource "aws_elb" "new-elb" {
  name            = "${var.elb_name}"
  subnets         = ["${split(",", var.subnets)}"]
  security_groups = ["${var.security_group_id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "${var.http_listener_elb_protocol}"
    instance_port     = "${var.http_listener_instance_port}"
    instance_protocol = "${var.http_listener_instance_protocol}"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "${var.https_listener_elb_protocol}"
    ssl_certificate_id = "${var.ssl_cert_id}"
    instance_port      = "${var.https_listener_instance_port}"
    instance_protocol  = "${var.https_listener_instance_protocol}"
  }

  health_check {
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    target              = "${var.health_check_target_proto}:${var.http_listener_instance_port}${var.health_check_http_path}"
    interval            = "${var.health_check_interval}"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining_enabled}"
  connection_draining_timeout = "${var.connection_draining_timeout}"
}
