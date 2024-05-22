# variable "region" {
#   description = "The region for Open Telekom Cloud"
#   type        = string
#   default     = "eu-de"
# }
#
variable "name" {
  description = "Name of the ECS"
  type        = string
  default     = "vpn-server"
}

variable "flavor_name" {
  description = "Flavour of the ECS"
  type        = string
  default     = "s3.medium.2"
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "ssh_public_keys" {
  description = "List of public SSH keys to put on the server"
  type        = list(string)
  default     = []
}

variable "network_mask" {
  description = "VPN network mask in CIDR notation"
  type        = string
}

variable "vpn_port" {
  description = "Port number for VPN connections used by Wireguard on both server' and clients' sides"
  type        = number
  default     = 51820
}

variable "service_port" {
  description = "Port number for the Kubernetes Service object"
  type        = number
  default     = 8000
}

variable "server_port_base" {
  description = "Initial value of the open port on VPN server to forward traffic to remote peers"
  type        = number
  default     = 8000
}

variable "namespace" {
  description = "Kubernetes namespace where to create Service objects"
  type        = string
}

variable "peers" {
  description = "Remote servers that must be Wireguard clients"
  type        = list(object({
    # Name defines a name of the Service in Kubernetes
    name = string
    # Name of the Kubernetes Service that will for
    service_name = string
    # Defines the IP address inside the VPN network, begins with 2. See the cidrhost() Terraform function
    host_num = number
    # Remote port (on the Wireguard client) where the application is running
    port = number
  }))
}

locals {
  # Wireguard server takes the first IP
  server_ip = cidrhost(var.network_mask, 1)

  peers = toset([
    for peer in var.peers : {
      # IP address in the VPN
      ip : cidrhost(var.network_mask, peer.host_num)
      name : peer.name
      port : peer.port
      # Port number on the VPN server that will forward traffic to the given peer
      server_port : var.server_port_base + peer.host_num
      # Name of the Service in Kubernetes cluster
      service_name : peer.service_name
    }
  ])
}

# variable "security_group_id" {
#   description = "The ID of the security group to assign to the instance"
#   type        = string
# }
#
# variable "key_pair" {
#   description = "The name of the key pair to use for the instance"
#   type        = string
# }
#
# variable "private_key" {
#   description = "The private key for WireGuard Server"
#   type        = string
# }
#
