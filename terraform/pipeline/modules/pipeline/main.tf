locals {
  bucket_name = var.name
}

resource "aws_codepipeline" "this" {

  name     = "${var.name}-deployment-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.this.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.repository.connection_arn
        FullRepositoryId = var.repository.full_repository_id
        BranchName       = var.repository.branch_name
      }
    }
  }

  dynamic "stage" {

    for_each = var.require_approval? [1]: []
    content {
      name = "Approval"

      action {
        name            = "ApprovalAction"
        category        = "Approval"
        owner           = "AWS"
        provider        = "Manual"
        version         = "1"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_artifacts"]
      version          = "1"

      configuration = {
        ProjectName = var.build_codebuild
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_artifacts"]
      version         = "1"

      configuration = {
        ProjectName = var.deploy_codebuild
      }
    }
  }

}

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "pipeline_role" {
  name               = "${var.name}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.repository.connection_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.pipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}
