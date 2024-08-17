variable "name" {
  type = string
}

variable "deployable_zip_path" {
  type = string
}

variable "environment_config" {
  type = map(string)
}

variable "api_gateway_stage_name" {
  type = string
}

variable "api_gateway_id" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type = string
}