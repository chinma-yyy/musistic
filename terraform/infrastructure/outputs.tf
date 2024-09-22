output "bastion_host_connect" {
  value = aws_instance.baston_host.public_ip
}

output "certificate_arn" {
  value = data.aws_acm_certificate.ssl_certficate.arn
}
