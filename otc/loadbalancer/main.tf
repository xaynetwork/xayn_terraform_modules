resource "opentelekomcloud_lb_loadbalancer_v3" "elb" {
  name        = "${var.name}-lb"
  router_id   = var.vpc_id
  network_ids = [var.subnet_id]

  availability_zones = var.availability_zones

  public_ip {
    id = opentelekomcloud_vpc_eip_v1.ingress_eip.id
  }
}

resource "opentelekomcloud_vpc_eip_v1" "ingress_eip" {
  bandwidth {
    charge_mode = "traffic"
    name        = "${var.name}-ingress-bandwidth"
    share_type  = "PER"
    size        = var.bandwidth
  }
  publicip {
    type = "5_bgp"
  }
}
