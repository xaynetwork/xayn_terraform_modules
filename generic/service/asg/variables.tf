variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

# optional parameters
variable "min_tasks" {
  description = "Min number of scalable service tasks"
  type        = number
  default     = 2
}

variable "max_tasks" {
  description = "Max number of scalable service tasks"
  type        = number
  default     = 4
}

variable "target_value" {
  description = "The target to keep the CPU utilization at"
  type        = number
  default     = 80

  validation {
    condition     = var.target_value > 0 && var.target_value <= 100
    error_message = "Target of the CPU utilization should be between 1 and 100"
  }
}

variable "scale_in_cooldown" {
  description = "Amount of time, in seconds, after a scale in activity completes before another scale in activity can start"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Amount of time, in seconds, after a scale out activity completes before another scale out activity can start"
  type        = number
  default     = 60
}

variable "scheduled_scaling" {
  description = "A list of schedule configurations in order to scale the service out and in."
  type = list(object({
    schedule_out = string
    schedule_in  = string
    timezone     = string
    min_out      = number
    max_out      = number
  }))
  default = []
}
