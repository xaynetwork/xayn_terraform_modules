resource "wireguard_asymmetric_key" "server" {}

resource "wireguard_asymmetric_key" "peer" {
  for_each = {
    for peer in local.peers : peer.name => peer
  }
}

data "wireguard_config_document" "server" {
  private_key = wireguard_asymmetric_key.server.private_key
  listen_port = var.vpn_port
  addresses   = [var.network_mask]

  dynamic peer {
    for_each = {
      for peer in local.peers : peer.name => peer
    }
    content {
      allowed_ips          = [peer.value.ip]
      persistent_keepalive = 25
      public_key           = wireguard_asymmetric_key.peer[peer.key].public_key
    }
  }
}

data "wireguard_config_document" "peer" {
  for_each = {
    for peer in local.peers : peer.name => peer
  }

  private_key = wireguard_asymmetric_key.peer[each.key].private_key
  addresses   = [each.value.ip]

  peer {
    # Only communication with VPN server is allowed
    allowed_ips          = [local.server_ip]
    endpoint             = format("%s:%s", opentelekomcloud_vpc_eip_v1.this.publicip[0].ip_address, var.vpn_port)
    persistent_keepalive = 25
    public_key           = wireguard_asymmetric_key.server.public_key
  }
}
