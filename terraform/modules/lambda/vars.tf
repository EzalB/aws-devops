variable "name_prefix" {
  type = string
}

variable "functions" {
  description = "List of lambda definitions"
  type = list(object({
    name    = string
    runtime = string
    handler = string
    s3_key  = string
    s3_bucket = optional(string)
    filename = optional(string) # local package zip - prefer s3 to avoid packaging in TF
    memory  = number
    timeout = number
    env     = map(string)
    role_arn = optional(string)
  }))
  default = []
}

variable "lambda_count" {
  type    = number
  default = 0
}

variable "tags" {
  type = map(string)
  default = {}
}
