terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }

  backend "s3" {
    bucket         = "cva-tf-remote-state-dev1"
    key            = "expense-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cva-state-locking"
    encrypt        = true
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}