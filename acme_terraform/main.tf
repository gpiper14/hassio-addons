variable "staging" {
  type = "string"
  default = "true"
}

variable "email" {
  type = "string"
}

variable "dns_names" {
  type = "list"
}

provider "acme" {
  server_url = "${var.staging ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory"}"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address = "${var.email}"
}

resource "acme_certificate" "certificate" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  common_name = "${element(var.dns_names, 0)}"
  subject_alternative_names = ["${var.dns_names}"]

  dns_challenge {
    provider = "route53"
  }
}

resource "local_file" "cert_file" {
  filename = "/ssl/fullchain.pem"
  content = "${acme_certificate.certificate.certificate_pem}"
}

resource "local_file" "key_file" {
  filename = "/ssl/privkey.pem"
  content = "${acme_certificate.certificate.private_key_pem}"
}
