resource "aws_acm_certificate" "cert" {
  domain_name       = "blog.${var.base_domain}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_acm_certificate.cert.domain_validation_options : record.resource_record_name]
}