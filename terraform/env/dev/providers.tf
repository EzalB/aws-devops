terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  merged_tags = merge(
    var.default_tags,
    {
      managed-by  = "terraform"
      environment = var.environment
    }
  )
}

provider "aws" {
  region  = var.aws_region

  default_tags {
    tags = local.merged_tags
  }
}