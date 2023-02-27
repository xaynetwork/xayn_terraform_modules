variable "name" {
  description = "The name for the ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnets" {
  description = "The IDs of the subnets to associate with the ALB"
  type        = list(string)
}

variable "subnets_cidr_blocks" {
  description = "The CIDR subnet blocks of the security group"
  type        = list(string)
}

variable "listener_port" {
  description = "Value of the port for the listener"
  type        = number
}

variable "listener_default_response" {
  description = "Default response if no rule matches"
  type = object({
    content_type = string
    message_body = string
    status_code  = string
  })
  default = {
    content_type = "text/plain"
    message_body = "Not Found"
    status_code  = "404"
  }
}

variable "health_check_path" {
  description = "The path of the ALB health check"
  type        = string
  default     = "/health"
}

variable "services_http_5xx_error" {
  description = "Alarm for ALB services HTTP-5XX errors."
  type        = map(any)
  default     = {}
}

variable "http_5xx_error" {
  description = "Alarm for ALB HTTP-5XX errors."
  type        = map(any)
  default     = {}
}

variable "http_4xx_error" {
  description = "Alarm for ALB HTTP-4XX errors."
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
