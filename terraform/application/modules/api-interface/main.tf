resource "aws_apigatewayv2_api" this {
  name          = var.name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" this {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "UGVX Blog Lambda Integration"
  integration_method   = "POST"
  integration_uri      = var.lambda_invocation_arn
  passthrough_behavior = "WHEN_NO_MATCH"
  timeout_milliseconds = 1000
}

resource "aws_apigatewayv2_stage" this {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "prod"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit = 1000
  }
}

resource "aws_apigatewayv2_route" this {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_domain_name" "this" {
  domain_name = var.base_domain

  domain_name_configuration {
    certificate_arn = var.existing_cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" this {
  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this.domain_name
  stage       = aws_apigatewayv2_stage.this.name
}