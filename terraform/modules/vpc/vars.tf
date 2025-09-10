variable "name" {
  type        = string
  description = "Name for VPC"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "AZs to use"
  default     = []
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets"
  default     = []
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets"
  default     = []
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Create NAT Gateway"
  default     = true
}

variable "tags" {
  description = "Tags map"
  type        = map(string)
  default     = {}
}
