
variable "name" {
  type        = string
  description = "The name for the role"
}

variable "description" {
  type        = string
  description = "The description of the role"
  default     = "Created by Terraform"
}

variable "display_layer" {
  type        = string
  description = "Wether it is displayed for the 'domain' or 'project'"
  default     = "domain"
}

variable "policy" {
  type = list(object({
    effect   = string
    action   = list(string)
    resource = list(string)
    }
  ))
  description = "The configuration of the policy to assign to the role. "
}
