variable "name" {
  type = string
}

variable "repository" {
  type = object({
    connection_arn     = string
    full_repository_id = string
    branch_name        = string
  })
}

variable "build_codebuild" {
  type = string
}

variable "deploy_codebuild" {
  type = string
}


variable "require_approval" {
  type = bool
}