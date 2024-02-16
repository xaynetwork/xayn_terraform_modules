data "onepassword_item" "ak" {
  vault = var.vault_id
  uuid  = var.access_key_uid
}

data "onepassword_item" "sk" {
  vault = var.vault_id
  uuid  = var.secret_key_uid
}
