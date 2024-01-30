variable "name" {
  description = "Name to assign to the helm chart"
  type        = string
}

variable "namespace_name" {
  description = "Name of the namespace if it needs to be created"
  type        = string
  default     = null
}

variable "repository_name" {
  description = "Name of the repository for the helm chart"
  type        = string
}

variable "config_file" {
  description = "The config file for the helm values"
  type        = string
}

variable "chart_version" {
  description = "The version of the ingress kong chart"
  type        = string
  default     = "v0.10.1"
}
