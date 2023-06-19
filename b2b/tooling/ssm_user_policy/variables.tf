variable "prefix" {
  description = "Name Prefix for this policy"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of the KMS key that is used by CloudWatch"
  type        = string
}

# optimal parameter
variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
