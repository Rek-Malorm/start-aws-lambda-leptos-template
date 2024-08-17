application_name = "{{project_name}}"
region= "{{region}}"
repository = {
  connection_arn = "{{codestar_connection_arn}}"
  full_repository_id = "{{git_repo}}"
  branch_name = "{{branch}}"
}
remote_state = {
  bucket = "{{remote_state_bucket}}"
  key_prefix = "{{remote_state_key}}"
}
application_config = {
  application_name = "{{project_name}}"
  region = "{{region}}"
  public_url = "{{website_url}}"
  aws_account_id = "{{aws_account_id}}"
  existing_cert_arn = "{{acm_cert_arn}}"
}