resource "aws_codebuild_project" "this" {

  name          = "${var.name}-build-rust-codebuild"
  description   = "Codebuild used to build Rust project"
  build_timeout = 15
  concurrent_build_limit = 1
  service_role  = aws_iam_role.this.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("./templates/buildspec_rust_build.yml")
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}

resource "aws_iam_role" "this" {
  name = "${var.name}-build-rust-codebuild"

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
  policy = <<EOF
{
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
}
EOF
}

resource "aws_iam_role_policy" "pipeline_bucket_access_inline_policy" {
  name   = "PipelineBucketAccessInlinePolicy"
  role   = aws_iam_role.this.id
  policy = <<EOF
{
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
}
EOF
}
