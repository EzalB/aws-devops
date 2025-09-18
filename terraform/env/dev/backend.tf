terraform {
  backend "s3" {
    bucket         = "ezalb-aws-devops-terraform-state"
    key            = "aws/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-terraform-locks"
    encrypt        = true
  }
}
