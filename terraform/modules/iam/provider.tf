terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM doesn’t need VPC/EKS provider aliases, only default AWS provider
provider "aws" {
  region = var.region
}
