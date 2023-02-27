variable "cluster_name" {
  description = "The name of the ECS cluster for use with CloudWatch Metrics."
  type        = string
}

variable "service_name" {
  description = "The name of the ECS service for use with CloudWatch Metrics."
  type        = string
  default     = "default"
}

variable "account_id" {
  description = "Specifies the ID of the account where the metric is located."
  type        = string
}

variable "prefix" {
  description = "Specifies a prefix for all alarm names."
  type        = string
  default     = ""
}

variable "cpu_usage" {
  description = "Alarm for Service average CPU usage. Threshold is in percentage."
  type        = any
  default     = {}
}

variable "log_error" {
  description = "Alarm for Service error log count."
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
