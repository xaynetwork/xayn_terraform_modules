variable "name" {
  description = "The name of the model (must be unique). If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "primary_container" {
  description = "The primary docker image containing inference code that is used when the model is deployed for predictions."
  type        = any
  default     = {}
}

variable "enable_network_isolation" {
  description = "Isolates the model container. No inbound or outbound network calls can be made to or from the model container."
  type        = bool
  default     = false
}

variable "vpc_config" {
  description = "Specifies the VPC that you want your model to connect to. VpcConfig is used in hosting services and in batch transform."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Custom tags to set on the underlining resources."
  type        = map(string)
  default     = {}
}
