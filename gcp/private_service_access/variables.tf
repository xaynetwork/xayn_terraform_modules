variable "network_id" {
  description = "The google_compute_network.network.id when creating the vpc network that should be peerd with the google services vpc"
  type        = string
}

variable "network_name" {
  description = "The google_compute_network.network.name when creating the vpc network that should be peerd with the google services vpc"
  type        = string
}

variable "prefix_length" {
  description = "The prefix length of the IP range. If not present, it means the address field is a single IP address. This field is not applicable to addresses with "
  type        = number
  default     = 16
}
