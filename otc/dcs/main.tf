data "opentelekomcloud_dcs_az_v1" "az_1" {
  name = var.region_zone
}

data "opentelekomcloud_dcs_product_v1" "product_1" {
  spec_code = var.spec_code
}

data "onepassword_item" "dcs_password" {
  vault = var.vault_id
  uuid  = var.dcs_password_uid
}

resource "opentelekomcloud_dcs_instance_v1" "instance_1" {
  name            = var.name
  engine_version  = var.engine_version
  password        = data.onepassword_item.dcs_password.password
  engine          = "Redis"
  capacity        = var.capacity
  vpc_id          = var.vpc_id
  subnet_id       = var.subnet_id
  available_zones = [data.opentelekomcloud_dcs_az_v1.az_1.id]
  product_id      = data.opentelekomcloud_dcs_product_v1.product_1.id
}
