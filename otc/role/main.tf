resource "opentelekomcloud_identity_role_v3" "role" {
  description   = var.description
  display_name  = var.name
  display_layer = var.display_layer
  dynamic "statement" {
    for_each = var.policy
    content {
      effect   = statement.value["effect"]
      action   = statement.value["action"]
      resource = statement.value["resource"]
    }
  }
}

