variable "name_prefix" {
  type = string
}

variable "repos" {
  description = "List of repository names to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(string)
  default = {}
}
