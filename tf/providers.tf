terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
  }
}

#A provider block without an alias argument is the default configuration for that provider. 
provider "aws" {
  region = var.aws-region
}

