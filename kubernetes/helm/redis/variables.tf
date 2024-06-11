variable "name" {
  default     = "redis"
  description = "Name of the Helm release"
  type        = string
}

variable "namespace" {
  description = "Namespace in the cluster"
  type        = string
}

variable "secret_name" {
  default     = "redis"
  description = "Name of the Kubernetes Secret that contains Redis password"
  type        = string
}

variable "secret_key_name" {
  default     = "redis-password"
  description = "Name of field in the Kubernetes Secret that contains Redis password"
  type        = string
}

variable "values" {
  default     = ""
  description = "YAML document that contains values fro the Helm chart"
  type        = string
}
