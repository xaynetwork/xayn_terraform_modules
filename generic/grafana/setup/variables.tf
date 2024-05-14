variable "grafana_url" {
  description = "URL to access grafana"
  type        = string
}

variable "contact_point_name" {
  type        = string
  description = "Name for the contact settings "
}

variable "slack_config" {
  description = "The slack configuration for the contact point"
  type = object({
    disable_resolve_message = bool
    mention_channel         = string
    mention_groups          = string
    mention_users           = string
    text                    = string
    title                   = string
    url                     = string
  })
  default = null
}

variable "email_config" {
  description = "The email configuration for the contact point"
  type = object({
    addresses               = list(string)
    disable_resolve_message = bool
    message                 = string
    settings                = map(list(string))
    single_email            = bool
    subject                 = string
  })
  default = null
}

variable "notification_policy" {
  description = "The global notification policy for Grafana"
  type = list(object({
    matcher = list(object({
      label = string
      match = string
      value = string
      })
    )
  }))
}
