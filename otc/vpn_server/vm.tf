data "opentelekomcloud_images_image_v2" "ubuntu" {
  most_recent = true
  name_regex  = "^Standard_Ubuntu_22\\.04.?"
  visibility  = "public"
}

resource "opentelekomcloud_compute_keypair_v2" "system" {
  name = var.name
}

resource "opentelekomcloud_compute_instance_v2" "this" {
  name        = var.name
  flavor_name = var.flavor_name
  image_id    = data.opentelekomcloud_images_image_v2.ubuntu.id

  key_pair = opentelekomcloud_compute_keypair_v2.system.name

  security_groups = [
    opentelekomcloud_networking_secgroup_v2.wireguard_server.name,
  ]

  user_data = templatefile("cloud-init/config.tftpl", {
    peers           = local.peers
    ssh_public_keys = jsonencode(var.ssh_public_keys)
    server_config   = jsonencode(data.wireguard_config_document.server.conf)
    #     private_key = var.private_key
  })

  network {
    uuid = var.subnet_id
  }
}
