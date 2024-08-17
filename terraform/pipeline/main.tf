
module "codepipeline" {
  source = "./modules/pipeline"

  name = var.application_name

  repository        = var.repository

  build_codebuild  = module.build_codebuild.codebuild_id
  deploy_codebuild = module.deploy_codebuild.codebuild_id
  require_approval = var.require_approval
}


module "build_codebuild" {
  source = "./modules/build_rust_codebuild"

  name                = var.application_name
  pipeline_bucket_arn = module.codepipeline.pipeline_bucket_arn
  pipeline_bucket_name = module.codepipeline.pipeline_bucket_name
}

module "deploy_codebuild" {
  source = "./modules/deploy_terraform_codebuild"

  name                = var.application_name
  pipeline_bucket_arn = module.codepipeline.pipeline_bucket_arn
  remote_state        = var.remote_state
  application_config  = var.application_config
}
