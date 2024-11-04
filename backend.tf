terraform {
  backend "s3" {
    bucket         = "frontend-s3-bucket-123456"
    key            = "terraform/state"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "frontend-lockfile"
  }
}

