variable "name" {
  type        = string
  description = "Project name."
}

variable "repository" {
  description = "Configuration of the repository settings"
  type = list(object({
    repository_name        = string
    repository_category    = string
    repository_description = string
    repository_public      = bool
  }))
}
