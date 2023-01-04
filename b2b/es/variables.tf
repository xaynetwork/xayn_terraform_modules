variable "name" {
  description = "The name for the ES resources"
  type        = string
}

variable "es_version" {
  description = "ES version to use for all the deployment resources"
  type        = string
  default     = "8.5.3"
}

variable "deployment_template" {
  description = "The ID of the ES cluster deployment"
  type        = string
  default     = "aws-cpu-optimized-arm-v5"
}

variable "hot_tier_memory_max" {
  description = "Specifies maximum value of the memory resources (GB) for elastic to autoscale"
  type        = number
  default     = 15
}

variable "hot_tier_memory" {
  description = "Specifies the initial memory size (GB) of the elastic deployment"
  type        = number
  default     = 1
}

variable "vpce_id" {
  description = "ID of the AWS side VPCE"
  type        = string
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
