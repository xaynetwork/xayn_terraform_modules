variable "permission_name" {
  description = "The name of the Permission Set"
  type        = string
}

variable "duration" {
  description = "The duration of the session for the SSO instance"
  type        = string
  default     = "PT10H"
}

variable "policy_name" {
  description = "The name of the policy to assign"
  type        = string
}

variable "actions" {
  description = "Actions applied to the policy"
  type        = list(string)
}

variable "resources" {
  description = "Resources to which applied to the policy"
  type        = list(string)
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
