# DynamoDB
resource "aws_dynamodb_table" "web_db" {
  name         = "web-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
