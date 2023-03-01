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

variable "alarm_all_requests" {
  description = "Alarm for WAF ALL requests."
  type        = any
  default     = {}
}

variable "alarm_all_requests_blocked" {
  description = "Alarm for WAF ALL blocked requests."
  type        = any
  default     = {}
}

variable "user_body_size" {
  description = "Size limit of the user API body from the load"
  type        = number
  default     = 8000
}

variable "doc_body_size" {
  description = "Size limit of the document API body from the load"
  type        = number
  default     = 4000000
}

variable "query_size" {
  description = "Size limit of the query from the load"
  type        = number
  default     = 1000
}

variable "headers_size" {
  description = "Size limit of the headers from the load"
  type        = number
  default     = 1000
}

variable "alarm_ip_rate_limit" {
  description = "Alarm for WAF ip rate limit"
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
