variable "db_cluster_identifier" {
  description = "The DB Cluster Identifier for use with CloudWatch Metrics."
  type        = string
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

variable "read_latency" {
  description = "Alarm for Aurora average read latency. Threshold is in milliseconds."
  type        = any
  default     = {}
}

variable "write_latency" {
  description = "Alarm for Aurora average write latency Threshold is in milliseconds."
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
