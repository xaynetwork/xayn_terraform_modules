data "opentelekomcloud_vpc_subnet_v1" "this" {
  id = var.subnet_id
}

resource "opentelekomcloud_networking_secgroup_v2" "wireguard_server" {
  name = "wireguard-server"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "wireguard" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = var.vpn_port
  port_range_max    = var.vpn_port
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.wireguard_server.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.wireguard_server.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "vllm" {
  for_each = {
    for peer in local.peers : peer.name => peer
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value.server_port
  port_range_max    = each.value.server_port
  remote_ip_prefix  = data.opentelekomcloud_vpc_subnet_v1.this.cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.wireguard_server.id
}
