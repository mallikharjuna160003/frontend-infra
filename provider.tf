terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  // Specify the version as needed
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

