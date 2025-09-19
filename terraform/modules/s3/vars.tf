variable "name_prefix" {
  description = "Prefix applied to bucket names"
  type        = string
}

variable "buckets" {
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

variable "block_public_acls" {
  type        = bool
  default     = true
}

variable "block_public_policy" {
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
