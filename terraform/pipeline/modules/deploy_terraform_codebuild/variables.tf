variable "name" {
  type = string
}

variable "pipeline_bucket_arn" {
  type = string
}

variable "remote_state" {
  type = object({
    bucket     = string
    key_prefix = string
  })
}

variable "application_config" {
}