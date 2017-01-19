
variable "region" {}
variable "instance_name" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
}

variable "iam_profile" {
}

variable "ami" {
  default = "ami-4bb3e05c"
}


provider "aws" {
  region     = "${var.region}"
}


resource "aws_security_group" "dev_node_access" {
  name        = "dev_node_access_${var.instance_name}"
  description = "development node security"

  # SSH access from anywhere, be careful!
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dev_node" {
  ami   = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  iam_instance_profile = "${var.iam_profile}"
  tags {
        Name = "${var.instance_name}"
  }
  provisioner "remote-exec" {
     connection {
        type = "ssh"
        user = "admin"
    }
    script = "provision.sh"
  }
  security_groups = ["dev_node_access"]
}

output "public_ips" {
    value = "${aws_instance.dev_node.public_ip}"
}
