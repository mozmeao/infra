variable "name" {}
variable "load_balancer" {}
variable "lb_port" {
	default = 443
}

resource "aws_lb_ssl_negotiation_policy" "sumo-stage-a-policy" {
  name          = "${var.name}"
  load_balancer = "${var.load_balancer}"
  lb_port       = "${var.lb_port}"

  attribute { name  = "Protocol-TLSv1" value = "true" }
  attribute { name  = "Protocol-TLSv1.1" value = "true" }
  attribute { name  = "Protocol-TLSv1.2" value = "true" }
  attribute { name  = "Protocol-SSLv3" value = "false" }

  # SSL Options

  attribute { name  = "Server-Defined-Cipher-Order" value = "true" }

  # SSL Ciphers
    attribute { name="ECDHE-ECDSA-AES128-GCM-SHA256" value="true"}
    attribute { name="ECDHE-RSA-AES128-GCM-SHA256" value="true"}
    attribute { name="ECDHE-ECDSA-AES128-SHA256" value="true"}
    attribute { name="ECDHE-RSA-AES128-SHA256" value="true"}
    attribute { name="ECDHE-ECDSA-AES128-SHA" value="true"}
    attribute { name="ECDHE-RSA-AES128-SHA" value="true"}
    attribute { name="DHE-RSA-AES128-SHA" value="false"}
    attribute { name="ECDHE-ECDSA-AES256-GCM-SHA384" value="true"}
    attribute { name="ECDHE-RSA-AES256-GCM-SHA384" value="true"}
    attribute { name="ECDHE-ECDSA-AES256-SHA384" value="true"}
    attribute { name="ECDHE-RSA-AES256-SHA384" value="true"}
    attribute { name="ECDHE-RSA-AES256-SHA" value="true"}
    attribute { name="ECDHE-ECDSA-AES256-SHA" value="true"}
    attribute { name="AES128-GCM-SHA256" value="true"}
    attribute { name="AES128-SHA256" value="true"}
    attribute { name="AES128-SHA" value="true"}
    attribute { name="AES256-GCM-SHA384" value="true"}
    attribute { name="AES256-SHA256" value="true"}
    attribute { name="AES256-SHA" value="true"}
    attribute { name="DHE-DSS-AES128-SHA" value="false"}
    attribute { name="CAMELLIA128-SHA" value="false"}
    attribute { name="EDH-RSA-DES-CBC3-SHA" value="false"}
    # allow windows xp to connect
    attribute { name="DES-CBC3-SHA" value="true"}
    attribute { name="ECDHE-RSA-RC4-SHA" value="false"}
    attribute { name="RC4-SHA" value="false"}
    attribute { name="ECDHE-ECDSA-RC4-SHA" value="false"}
    attribute { name="DHE-DSS-AES256-GCM-SHA384" value="false"}
    attribute { name="DHE-RSA-AES256-GCM-SHA384" value="false"}
    attribute { name="DHE-RSA-AES256-SHA256" value="false"}
    attribute { name="DHE-DSS-AES256-SHA256" value="false"}
    attribute { name="DHE-RSA-AES256-SHA" value="false"}
    attribute { name="DHE-DSS-AES256-SHA" value="false"}
    attribute { name="DHE-RSA-CAMELLIA256-SHA" value="false"}
    attribute { name="DHE-DSS-CAMELLIA256-SHA" value="false"}
    attribute { name="CAMELLIA256-SHA" value="false"}
    attribute { name="EDH-DSS-DES-CBC3-SHA" value="false"}
    attribute { name="DHE-DSS-AES128-GCM-SHA256" value="false"}
    attribute { name="DHE-RSA-AES128-GCM-SHA256" value="false"}
    attribute { name="DHE-RSA-AES128-SHA256" value="false"}
    attribute { name="DHE-DSS-AES128-SHA256" value="false"}
    attribute { name="DHE-RSA-CAMELLIA128-SHA" value="false"}
    attribute { name="DHE-DSS-CAMELLIA128-SHA" value="false"}
    attribute { name="ADH-AES128-GCM-SHA256" value="false"}
    attribute { name="ADH-AES128-SHA" value="false"}
    attribute { name="ADH-AES128-SHA256" value="false"}
    attribute { name="ADH-AES256-GCM-SHA384" value="false"}
    attribute { name="ADH-AES256-SHA" value="false"}
    attribute { name="ADH-AES256-SHA256" value="false"}
    attribute { name="ADH-CAMELLIA128-SHA" value="false"}
    attribute { name="ADH-CAMELLIA256-SHA" value="false"}
    attribute { name="ADH-DES-CBC3-SHA" value="false"}
    attribute { name="ADH-DES-CBC-SHA" value="false"}
    attribute { name="ADH-RC4-MD5" value="false"}
    attribute { name="ADH-SEED-SHA" value="false"}
    attribute { name="DES-CBC-SHA" value="false"}
    attribute { name="DHE-DSS-SEED-SHA" value="false"}
    attribute { name="DHE-RSA-SEED-SHA" value="false"}
    attribute { name="EDH-DSS-DES-CBC-SHA" value="false"}
    attribute { name="EDH-RSA-DES-CBC-SHA" value="false"}
    attribute { name="IDEA-CBC-SHA" value="false"}
    attribute { name="RC4-MD5" value="false"}
    attribute { name="SEED-SHA" value="false"}
    attribute { name="DES-CBC3-MD5" value="false"}
    attribute { name="DES-CBC-MD5" value="false"}
    attribute { name="RC2-CBC-MD5" value="false"}
    attribute { name="PSK-AES256-CBC-SHA" value="false"}
    attribute { name="PSK-3DES-EDE-CBC-SHA" value="false"}
    attribute { name="KRB5-DES-CBC3-SHA" value="false"}
    attribute { name="KRB5-DES-CBC3-MD5" value="false"}
    attribute { name="PSK-AES128-CBC-SHA" value="false"}
    attribute { name="PSK-RC4-SHA" value="false"}
    attribute { name="KRB5-RC4-SHA" value="false"}
    attribute { name="KRB5-RC4-MD5" value="false"}
    attribute { name="KRB5-DES-CBC-SHA" value="false"}
    attribute { name="KRB5-DES-CBC-MD5" value="false"}
    attribute { name="EXP-EDH-RSA-DES-CBC-SHA" value="false"}
    attribute { name="EXP-EDH-DSS-DES-CBC-SHA" value="false"}
    attribute { name="EXP-ADH-DES-CBC-SHA" value="false"}
    attribute { name="EXP-DES-CBC-SHA" value="false"}
    attribute { name="EXP-RC2-CBC-MD5" value="false"}
    attribute { name="EXP-KRB5-RC2-CBC-SHA" value="false"}
    attribute { name="EXP-KRB5-DES-CBC-SHA" value="false"}
    attribute { name="EXP-KRB5-RC2-CBC-MD5" value="false"}
    attribute { name="EXP-KRB5-DES-CBC-MD5" value="false"}
    attribute { name="EXP-ADH-RC4-MD5" value="false"}
    attribute { name="EXP-RC4-MD5" value="false"}
    attribute { name="EXP-KRB5-RC4-SHA" value="false"}
    attribute { name="EXP-KRB5-RC4-MD5" value="false"}
}

