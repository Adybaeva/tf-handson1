terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "my-first-bucket-backend"
    key    = "batch-14-tf-handson1"
    dynamodb_table = "tf-state-lock-dynamo"
  }
}