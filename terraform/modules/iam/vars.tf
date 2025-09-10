variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags applied to all IAM resources"
  default = {
    Project     = "todo-app"
    Environment = "dev"
  }
}
