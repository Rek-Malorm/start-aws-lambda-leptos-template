resource "aws_dynamodb_table" "index_table" {
  name           = var.index_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "document_name"
#  range_key      = "document_type"

  attribute {
    name = "document_name"
    type = "S"
  }
}