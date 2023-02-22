variable "permission_name" {
  description = "The name of the Permission Set"
  type        = string
}

variable "permission_description" {
  description = "Description of the Permission Set"
  type        = string
}

variable "duration" {
  description = "The duration of the SSO session"
  type        = string
  default     = "PT10H"
}

variable "managed_policies_arns" {
  description = "The ARN of the AWS managed policy"
  type        = list(string)
  default     = []
}

variable "customer_managed_policy_references" {
  description = "Customer managed policy references"
  type = list(object({
    name = string
    path = string
  }))
  default = []
}

variable "inline_policy_statements" {
  description = "Inline policy statements"
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
