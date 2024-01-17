variable "name" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "network_id" {
  type = string
}

variable "subnetwork_id" {
  type = string
}

variable "cluster_secondary_range_name" {
  type    = string
  default = "pods"
}

variable "services_secondary_range_name" {
  type    = string
  default = "services"
}

variable "master_ipv4_cidr_block" {
  type = string
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}
