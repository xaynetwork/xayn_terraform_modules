variable "permission_name" {
  description = "The name of the Permission Set"
  type        = string
}

variable "permission_description" {
  description = "Description for the permission"
  type        = string
}

variable "duration" {
  description = "The duration of the session for the SSO instance"
  type        = string
  default     = "PT10H"
}

variable "policy_name" {
  description = "Name of the newly created policies"
  type        = string
  default     = ""
}

variable "managed_policies_arns" {
  description = "Policy to add to permission set"
  type        = list(string)
  default     = []
}

variable "policy_conf" {
  description = "Policy to add to permission set"
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  default = null
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
