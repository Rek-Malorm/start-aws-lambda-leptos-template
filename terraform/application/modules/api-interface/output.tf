output "webpage_url" {
  value = aws_apigatewayv2_domain_name.this.domain_name
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.this.id
}

output "api_stage_name" {
  value = aws_apigatewayv2_stage.this.name
}

output "aws_acm_cert_validation_records" {
  value = var.create_cert ? module.cert[0].domain_validation_options : []
}

