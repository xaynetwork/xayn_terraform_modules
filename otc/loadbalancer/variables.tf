variable "name" {
  type        = string
  description = "Project name."
}
variable "bandwidth" {
  type        = number
  default     = 300
  description = "The bandwidth size. The value ranges from 1 to 1000 Mbit/s."
}
variable "subnet_id" {
  type        = string
  description = "Subnets where the elastic load balancer will be created."
}
variable "availability_zones" {
  type        = list(string)
  description = "Specifies the availability zones where the LoadBalancer will be located."
}
