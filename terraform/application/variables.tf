variable "application_name" {
  type = string
}

variable "public_url" {
  type = string
}

variable "region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "create_cert" {
  type = bool
}

variable "existing_cert_arn" {
  type = string
}