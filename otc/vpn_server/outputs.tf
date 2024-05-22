output "private_ip" {
  value = opentelekomcloud_compute_instance_v2.this.access_ip_v4
}

output "public_ip" {
  value = opentelekomcloud_vpc_eip_v1.this.publicip[0].ip_address
}

output "wg_config_server" {
  value     = data.wireguard_config_document.server.conf
  sensitive = true
}

output "wg_config_peer" {
  value     = { for key, peer in local.peers : peer.name => data.wireguard_config_document.peer[peer.name].conf }
  sensitive = true
}
