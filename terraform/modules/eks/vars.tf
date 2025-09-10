variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "node_groups" {
  description = "List of managed node groups"
  type = list(object({
    name             = string
    instance_types   = list(string)
    desired_capacity = number
    min_size         = number
    max_size         = number
    disk_size        = number
    labels           = map(string)
    tags             = map(string)
  }))
  default = []
}

variable "fargate_profiles" {
  description = "Optional fargate profiles"
  type = list(object({
    name              = string
    selectors         = list(object({ namespace = string }))
    pod_execution_role_arn = string
  }))
  default = []
}

variable "eks_oidc_enabled" {
  description = "Create OIDC provider for IRSA"
  type        = bool
  default     = true
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
