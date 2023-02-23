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

variable "create_alarms" {
  description = "Whether to create WAF alarms"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
  default     = null
}

variable "all_requests_threshold" {
  description = "Threshold of all WAF requests"
  type        = number
  default     = 40000
}

variable "all_blocked_requests_threshold" {
  description = "Threshold of all blocked WAF requests"
  type        = number
  default     = 5000
}

variable "ip_rate_limit_threshold" {
  description = "Threshold of the WAF ip rate limit"
  type        = number
  default     = 0
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
