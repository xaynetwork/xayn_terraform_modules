variable "sns_arn" {
  description = "ARN from the SNS topic"
  type        = string
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
