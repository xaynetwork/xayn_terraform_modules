resource "opentelekomcloud_vpc_eip_v1" "this" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name       = var.name
    size       = 10
    share_type = "PER"
  }
}

resource "opentelekomcloud_networking_floatingip_associate_v2" "this" {
  floating_ip = opentelekomcloud_vpc_eip_v1.this.publicip[0].ip_address
  port_id     = opentelekomcloud_compute_instance_v2.this.network[0].port
}
