resource "aws_codebuild_project" "this" {

  name          = "${var.name}-deploy-terraform-codebuild"
  description   = "Codebuild used to deploy terraform project"
  build_timeout = 15
  service_role  = aws_iam_role.this.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("./templates/buildspec_terraform_deploy.yml", {
      "remote_state_bucket" = var.remote_state.bucket
      "remote_state_key"    = "${var.remote_state.key_prefix}application"
      "tfvars_content"      = jsonencode(var.application_config)
    })
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

}

resource "aws_iam_role" "this" {
  name = "${var.name}-deploy-terraform-codebuild"

  description        = "Role to be used by codebuild when deploying terraform project"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json

}

data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cloudwatch_write_inline_policy" {
  name   = "CloudwatchWriteInlinePolicy"
  role   = aws_iam_role.this.id
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
})
}

resource "aws_iam_role_policy" "pipeline_bucket_access_inline_policy" {
  name   = "PipelineBucketAccessInlinePolicy"
  role   = aws_iam_role.this.id
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketAcl"
      ],
      "Resource": [
        "${var.pipeline_bucket_arn}",
        "${var.pipeline_bucket_arn}/*"
      ]
    }
  ]
})
}

resource "aws_iam_role_policy" "state_bucket_access_inline_policy" {
  name   = "StateBucketAccessInlinePolicy"
  role   = aws_iam_role.this.id
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.remote_state.bucket}",
        "arn:aws:s3:::${var.remote_state.bucket}/*"
      ]
    }
  ]
})

}

resource "aws_iam_role_policy" "deploy_access" {
  name = "TerraformApplyInlinePolicy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "ssm:*",
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "sts:*",
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "acm:*",
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:*",
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:*",
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "cloudfront:*",
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "route53:*",
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "apigateway:*",
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:PublishVersion",
          "lambda:CreateAlias",
          "lambda:GetAlias",
          "lambda:DeleteAlias",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:CreateFunctionUrlConfig",
          "lambda:GetFunctionUrlConfig",
          "lambda:DeleteFunctionUrlConfig",
          "lambda:AddPermission",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateAlias",
          "Lambda:UpdateFunctionConfiguration",
          "Lambda:GetPolicy",
          "Lambda:CreatePolicy",
          "Lambda:DeletePolicy",
          "Lambda:RemovePermission"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:UpdateAssumeRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRole",
          "iam:PassRole",
          "iam:CreatePolicy",
          "iam:GetPolicy",
          "iam:DeletePolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions"
        ],
        "Resource": "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:*"
        ],
        Resource = "*"
      },
    ]
  })
}
