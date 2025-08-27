variable "bucket_prefix" {
  type        = string
  default     = ""
  description = "Prefix of the S3 bucket"
}

#variable "bucket" {
#  type        = string
#  default     = ""
#  description = "Name of the S3 bucket"
#}

variable "force_destroy" {
  description = "Whether to force destroy the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = false
}

variable "enable_lifecycle_rule" {
  description = "Enable lifecycle rule for the bucket"
  type        = bool
  default     = false
}

variable "lifecycle_rule_days" {
  description = "Number of days after which objects are deleted (if lifecycle enabled)"
  type        = number
  default     = 30
}

variable "expiration_days" {
  description = "Number of days after which objects are deleted (if lifecycle enabled)"
  type        = number
  default     = 30
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

variable "location" {
  type = string
  default = "eu-north1"
  description = "Location for S3"
}

variable "transition_storage_class" {
  type = string
  default = "STANDARD_IA"
  description = "Storage class for the new bucket."
}
