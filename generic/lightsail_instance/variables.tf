variable "service_name" {
  description = " The name for the instance service."
  type        = string
}

variable "zone" {
  description = " The availability zone of the instance."
  type        = string
}

variable "blueprint_id" {
  description = " Which OS + App should be used for this instance. (see aws lightsail get-blueprints)"
  type        = string
  default     = "debian_11"
}

variable "bundle_id" {
  description = "What power configuration should be used for this instance. (see aws lightsail get-bundles)"
  type        = string
}

variable "user_data" {
  description = "Initial installation script, by befault this installs docker."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The name of the DNS region."
  type        = string
}

variable "subdomain_name" {
  description = "The domain name for the app."
  type        = string
}
