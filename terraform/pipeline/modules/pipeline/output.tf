output "pipeline_bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "pipeline_bucket_name" {
  value = local.bucket_name
}