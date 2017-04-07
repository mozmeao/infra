resource "aws_elb" "new-elb" {
  name      = "${var.elb_name}"
  instances = ["${split(",", var.instances)}"]
  subnets   = ["${split(",", var.subnets)}"]

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
    healthy_threshold   = 2
    unhealthy_threshold = 6
    timeout             = 5
    target              = "HTTP:${var.http_listener_instance_port}/"
    interval            = 10
  }

  instances                   = ["${split(",", var.instances)}"]
  cross_zone_load_balancing   = true
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining_enabled}"
  connection_draining_timeout = "${var.connection_draining_timeout}"
}
