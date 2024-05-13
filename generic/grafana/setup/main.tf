resource "grafana_contact_point" "this" {
  name = var.contact_point_name

  dynamic "slack" {
    for_each = var.slack_config != null ? [1] : []

    content {
      disable_resolve_message = var.slack_config.disable_resolve_message
      mention_channel         = var.slack_config.mention_channel
      mention_groups          = var.slack_config.mention_groups
      mention_users           = var.slack_config.mention_users
      text                    = var.slack_config.text
      title                   = var.slack_config.title
      url                     = var.slack_config.url
    }
  }

  dynamic "email" {
    for_each = var.email_config != null ? [1] : []

    content {
      addresses               = var.email_config.addresses
      disable_resolve_message = var.email_config.disable_resolve_message
      message                 = var.email_config.message
      settings                = var.email_config.settings
      single_email            = var.email_config.single_email
      subject                 = var.email_config.subject
    }
  }
}

resource "grafana_notification_policy" "this" {
  group_by      = ["..."]
  contact_point = grafana_contact_point.this.name

  group_wait      = "45s"
  group_interval  = "6m"
  repeat_interval = "3h"

  dynamic "policy" {
    for_each = var.notification_policy != null ? var.notification_policy : []

    content {
      dynamic "matcher" {
        for_each = var.notification_policy[policy.key].matcher != null ? var.notification_policy[policy.key].matcher : []

        content {
          label = var.notification_policy[policy.key].label
          match = var.notification_policy[policy.key].match
          value = var.notification_policy[policy.key].value
        }
      }
      contact_point = grafana_contact_point.this.name
      continue      = true
    }
  }
}
