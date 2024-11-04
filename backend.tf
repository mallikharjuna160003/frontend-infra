terraform {
  backend "s3" {
    bucket         = "frontend-s3-bucket-123456"
    key            = "terraform/state"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "frontend-lockfile"
  }
}

