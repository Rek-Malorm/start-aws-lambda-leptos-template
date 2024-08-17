resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : "AssumeRole"
      }
    ]
  })
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  handler       = "bootstrap"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"

  filename = var.deployable_zip_path
  source_code_hash = filebase64sha256(var.deployable_zip_path)

  environment {
    variables = merge(var.environment_config,
      {
        "RUST_BACKTRACE"      = "1"
        "LEPTOS_ENV"          = "PROD",
        "LEPTOS_OUTPUT_NAME"  = var.name,
        "LEPTOS_SITE_ROOT"    = "target/site",
        "LEPTOS_SITE_PKG_DIR" = "pkg"
      }
    )
  }

  publish = true
}

resource "aws_lambda_permission" "api_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  // Note the change here to target the alias
  function_name = "${aws_lambda_function.this.function_name}:${aws_lambda_alias.this.name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${var.api_gateway_id}/${var.api_gateway_stage_name}/$default"
}

resource "aws_lambda_alias" "this" {
  name             = "web-target"
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.name}"

  retention_in_days = 30
}

resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.name}-lambda_logging_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      },
    ]
  })
}