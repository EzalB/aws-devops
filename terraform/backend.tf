terraform {
  backend "s3" {
    bucket         = "devops-terraform-state"
    key            = "aws/infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
