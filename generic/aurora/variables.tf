variable "name" {
  description = "The name for the Aurora resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "vpc_database_subnet_group_name" {
  description = "The name of the subnet group name"
  type        = string
}

variable "vpc_private_subnets_cidr_blocks" {
  description = "The CIDR subnet blocks of the security group"
  type        = list(string)
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not"
  type        = bool
  default     = null
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = null
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  type        = bool
  default     = null
}

variable "instances" {
  description = "Map of cluster instances and any specific/overriding attributes to be created"
  type        = any
  default = {
    one = {}
    two = {}
  }
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "master_password" {
  description = "Password for the master DB user"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Boolean value to determine whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = false
}

variable "engine_version" {
  description = "The version of the db engine"
  type        = string
  default     = "14.5"
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 1
}

variable "min_scaling" {
  description = "The minimum capacity for an Aurora DB cluster in serverless DB engine mode"
  type        = number
  default     = 0.5
}

variable "max_scaling" {
  description = "The maximum capacity for an Aurora DB cluster in serverless DB engine mode"
  type        = number
  default     = 4.0
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance."
  type        = number
  default     = 15
}

variable "alarm_read_latency" {
  description = "Alarm for Aurora average read latency. Threshold is in milliseconds."
  type        = any
  default     = {}
}

variable "alarm_write_latency" {
  description = "Alarm for Aurora average write latency Threshold is in milliseconds."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
