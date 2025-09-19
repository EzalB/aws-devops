variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ---------------- VPC ----------------
#variable "vpc_cidr_block" {
#  description = "CIDR block for the VPC"
#  type        = string
#}
#
#variable "vpc_azs" {
#  description = "List of availability zones for subnets"
#  type        = list(string)
#}
#
#variable "vpc_public_subnet_cidrs" {
#  description = "CIDRs for public subnets"
#  type        = list(string)
#}
#
#variable "vpc_private_subnet_cidrs" {
#  description = "CIDRs for private subnets"
#  type        = list(string)
#}
#
#variable "vpc_enable_nat_gateway" {
#  description = "Enable NAT gateway in the VPC"
#  type        = bool
#}

# ---------------- ECR ----------------
variable "ecr_repos" {
  description = "List of ECR repository names"
  type        = list(string)
}

# ---------------- S3 ----------------
variable "s3_buckets" {
  description = "List of S3 buckets to create with attributes"
  type = list(object({
    name                      = string
    versioning                = bool
    location                  = optional(string, "us-east-1")
    force_destroy             = optional(bool, false)
    enable_lifecycle_rule     = optional(bool, false)
    lifecycle_rule_days       = optional(number, 30)
    expiration_days           = optional(number, 365)
    transition_storage_class  = optional(string, "STANDARD_IA")
  }))
}

# ---------------- EKS ----------------
#variable "eks_cluster_version" {
#  description = "EKS Kubernetes version"
#  type        = string
#}
#
#variable "eks_node_groups" {
#  description = "List of node groups for EKS"
#  type = list(object({
#    name             = string
#    instance_types   = list(string)
#    desired_capacity = number
#    min_size         = number
#    max_size         = number
#    disk_size        = number
#    labels           = map(string)
#    tags             = map(string)
#  }))
#}
#
#variable "eks_fargate_profiles" {
#  description = "List of fargate profiles for EKS"
#  type        = list(any)
#}
#
#variable "eks_oidc_enabled" {
#  description = "Enable OIDC provider for EKS cluster"
#  type        = bool
#}
#
## ---------------- Lambda ----------------
#variable "lambda_count" {
#  description = "Number of Lambda functions to create"
#  type        = number
#}
#
#variable "lambda_functions" {
#  description = "List of Lambda function configurations"
#  type = list(object({
#    name    = string
#    runtime = string
#    handler = string
#    s3_key  = string
#    memory  = number
#    timeout = number
#    env     = map(string)
#  }))
#}