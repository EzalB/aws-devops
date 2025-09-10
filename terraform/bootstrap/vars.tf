variable "aws_region" {
  type        = string
  description = "AWS region where to create backend resources"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of DynamoDB table for state locking"
  default     = "terraform-state-locks"
}

variable "tags" {
  type        = map(string)
  description = "Tags for backend resources"
  default     = {
    Project = "terraform-backend"
  }
}
