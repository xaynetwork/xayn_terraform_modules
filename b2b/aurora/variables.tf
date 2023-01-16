variable "name" {
  description = "The name for the Aurora resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnets" {
  description = "The IDs of the subnets to associate with Aurora"
  type        = list(string)
}

variable "subnets_cidr_blocks" {
  description = "The CIDR subnet blocks of the security group"
  type        = list(string)
}

variable "db_admin_username" {
  description = "Database administrator username"
  type        = string
}

variable "db_admin_password" {
  description = "Database administrator password"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Boolean value to determine whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = false
}

variable "instance_count" {
  description = "The number of instances to deploy"
  type        = number
}

variable "instance_class" {
  description = "The class of the instances to deploy"
  type        = string
  default     = "db.serverless"
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

variable "create_alarms" {
  description = "Whether to create Aurora alarms"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
  default     = null
}

variable "read_latency_threshold" {
  description = "Threshold of the average Aurora read latency in milliseconds"
  type        = number
  default     = 10
}

variable "write_latency_threshold" {
  description = "Threshold of the average Aurora write latency in milliseconds"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
