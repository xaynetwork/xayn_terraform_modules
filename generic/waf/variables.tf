variable "blacklist" {
  description = "IPV4 addresses (CIDR notation 1.1.1.1/32) that should be part of the blacklist"
  type        = list(string)
  default     = []
}

variable "whitelist" {
  description = "IPV4 addresses (CIDR notation 1.1.1.1/32) that should be part of the whitelist"
  type        = list(string)
  default     = []
}

variable "ip_rate_limit" {
  description = "Maximum number of allowed requests for every 5 minutes"
  type        = number
  default     = 2000
}

#  i.e.: [
#       {
#         name        = "user-path"
#         url_segment = "/default/users"
#         priority    = 50
#       },
#       {
#         name        = "document-path"
#         url_segment = "/default/documents"
#         priority    = 60
#     } ]
variable "path_rules" {
  type = list(object({
    name        = string
    url_segment = string
    priority    = number
  }))
  description = "A list of path entry objects, that describe which paths are allowed by the firewall, an empty array would block all requests."
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
