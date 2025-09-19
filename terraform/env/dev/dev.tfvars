environment = "dev"
aws_region  = "us-east-1"

default_tags = {
  Project = "aws-devops"
  Owner   = "EzalB"
  Environment = "dev"
}

## VPC
#vpc_cidr_block           = "10.0.0.0/16"
#vpc_azs                  = ["us-east-1a", "us-east-1b"]
#vpc_public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
#vpc_private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
#vpc_enable_nat_gateway   = true

# ECR
ecr_repos = [
  "todo-service"
]

# S3
s3_buckets = [
  { name = "todo-service-logs",     versioning = true },
  { name = "notifier-service-logs", versioning = false }
]

## EKS
#eks_cluster_version = "1.28"
#eks_oidc_enabled    = true
#
#eks_node_groups = [
#  {
#    name             = "ng-general"
#    instance_types   = ["t3.medium"]
#    desired_capacity = 2
#    min_size         = 1
#    max_size         = 3
#    disk_size        = 50
#  },
#  {
#    name             = "ng-spot"
#    instance_types   = ["t3.medium"]
#    desired_capacity = 1
#    min_size         = 1
#    max_size         = 2
#    disk_size        = 50
#    capacity_type    = "SPOT"
#  }
#]
#
#eks_fargate_profiles = []
#
## Lambda
#lambda_count = 1
#
#lambda_functions = [
#  {
#    name    = "dev-processor"
#    runtime = "python3.10"
#    handler = "handler.handler"
#    s3_key  = ""
#    memory  = 512
#    timeout = 30
#    env     = {
#      ENV = "dev"
#      LOG_LEVEL = "INFO"
#    }
#  }
#]