locals {
}

module "ui_lambda" {
  source = "./modules/frontend-renderer-lambda"

  depends_on = []

  name = var.application_name

  deployable_zip_path = "../../release/deployable.zip"
  environment_config  = {
    "RUST_BACKTRACE"            = "1"
  }
  api_gateway_id         = module.api_gateway.api_gateway_id
  api_gateway_stage_name = module.api_gateway.api_stage_name
  aws_account_id         = var.aws_account_id
  aws_region             = var.region
}

module "api_gateway" {
  source = "./modules/api-interface"

  name                  = var.application_name
  lambda_invocation_arn = module.ui_lambda.invoke_arn
  base_domain           = var.public_url
  existing_cert_arn     = var.existing_cert_arn
  create_cert           = var.create_cert
}