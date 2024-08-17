terraform {
  backend "s3" {
    bucket = "{{remote_state_bucket}}"
    key    = "{{remote_state_key}}/pipeline"
    region = "{{region}}"
  }
}