resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name = "tf-state-lock-dynamo"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}