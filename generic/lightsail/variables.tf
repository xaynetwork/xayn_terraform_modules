variable "service_name" {
  description = " The name for the container service."
  type        = string
}

variable "power" {
  description = "The power specifies the amount of memory, the number of vCPUs, and the monthly price of each node of the container service."
  type        = string
}

variable "node_number" {
  description = "The allocated compute nodes of the container service."
  type        = number
}

variable "repository_name" {
  type        = string
  description = "Name of the private ECR repo to download images."
}

## Container information

variable "container_image" {
  description = " The name of the container image."
  type        = string
}

variable "container_port" {
  description = "The number of the port to access the container."
  type        = number
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
