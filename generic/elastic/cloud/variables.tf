variable "name" {
  description = "Name for the deployment."
  type        = string
}

variable "alias" {
  description = "Deployment alias, affects the format of the resource URLs."
  type        = string
  default     = null
}

variable "es_version" {
  description = "ES version to use for all the deployment resources"
  type        = string
  default     = "8.8.0"
}

variable "deployment_template" {
  description = "Deployment template identifier to create the deployment from."
  type        = string
  default     = "aws-cpu-optimized-arm-v6"
}

variable "hot_tier_memory_max" {
  description = "Specifies maximum value of the memory resources (GB) for elastic to auto-scale"
  type        = number
  default     = 15
}

variable "hot_tier_zone_count" {
  description = "Specifies the number of zones for this deployment. (Valid 1, 2, 3)"
  type        = number
  default     = 2

  validation {
    condition     = var.hot_tier_zone_count > 0 && var.hot_tier_zone_count < 4
    error_message = "Valid values are 1, 2, 3"
  }
}

variable "hot_tier_memory" {
  description = "Specifies the initial memory size (GB) of the elastic deployment"
  type        = number
  default     = 1
}

variable "ml_tier_memory" {
  description = "Specifies the initial memory size (GB) of the elastic deployment"
  type        = number
  default     = 0
}

variable "ml_tier_memory_max" {
  description = "Specifies maximum value of the memory resources (GB) for elastic to auto-scale"
  type        = number
  default     = 1
}

variable "ml_tier_zone_count" {
  description = "Specifies the number of zones for this deployment. (Valid 1, 2, 3)"
  type        = number
  default     = 1

  validation {
    condition     = var.ml_tier_zone_count > 0 && var.ml_tier_zone_count < 4
    error_message = "Valid values are 1 - 3"
  }
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
