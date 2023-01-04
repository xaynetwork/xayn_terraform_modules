variable "name" {
  description = "The name assigned to the bucket"
  type        = string
}

variable "acl" {
  description = "The ACL applied to the bucket"
  type        = string
}

variable "versioning" {
  description = "Map of the versioning configuration"
  type        = map(string)
}

variable "repositories" {
  description = "List of GitHub repositories to implement the role"
  type        = list(string)
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
