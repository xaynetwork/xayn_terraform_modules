data "onepassword_item" "item" {
  vault = var.vault_id
  uuid  = var.item_uid
}
