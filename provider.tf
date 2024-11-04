provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  // Specify the version as needed
    }
  }
}
