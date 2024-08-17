variable "application_name" {
  type = string
}

variable "region" {
    type = string
}

variable "repository" {
  type = object({
    connection_arn = string
    full_repository_id = string
    branch_name = string
  })
}

variable "remote_state" {
  type = object({
    bucket = string
    key_prefix = string
  })
}

variable "application_config" {
}

variable "require_approval" {
  type = bool
  default = true
}