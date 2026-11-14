terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.37.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }

  backend "s3" {
    bucket         = "shivakrishna-tf-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    #use_lockfile   = true
    #dynamodb_table = "vosukula-state-locking"
  }
}

#provider "aws" {
#  # Configuration options
#  region = "us-east-1"
#}
