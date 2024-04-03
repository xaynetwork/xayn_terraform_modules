
resource "random_id" "id" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "key" {
  key_alias       = "${var.name}-${random_id.id.hex}"
  key_description = var.description
  pending_days    = var.pending_days
  realm           = var.region_zone

  lifecycle {
    ignore_changes = [realm]
  }
}
