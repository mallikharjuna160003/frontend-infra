terraform {

  backend "s3" {
    bucket         = "frontend-s3-bucket-123456" // Your S3 bucket for storing the state
    key            = "terraform/state" // The path to your state file in the bucket
    region         = "us-west-2" // The region where your S3 bucket is located
    encrypt        = true // Encrypt the state file at rest
    dynamodb_table = "frontend-lockfile" // Your DynamoDB table for state locking
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  // Specify the version as needed
    }
  }
}
provider "aws" {
  region = "us-west-2"
}

