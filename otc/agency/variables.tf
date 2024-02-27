variable "name" {
  type        = string
  description = "The name agency"
}

variable "description" {
  type        = string
  description = "The description of the agency"
  default     = "Created by Terraform"
}

variable "delegated_domain_name" {
  type        = string
  description = "The delegation domain (i.e. op_svc_evs, op_svc_cce, ...)"

}

variable "projects" {
  type = list(object({
    project_name = string
    roles        = list(string)
    }
  ))
  description = "The roles that should be assigned to the projects. "
  default     = []
}

