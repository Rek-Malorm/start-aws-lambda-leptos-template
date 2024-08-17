

variable "name" {
  type = string
}

variable "lambda_invocation_arn" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "create_cert" {
  type = bool
}

variable "existing_cert_arn" {
  type = string
}