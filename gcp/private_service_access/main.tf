# If Private Service Access (PSA) is enabled,
# let's reserve IPs for peering (for private access to GCP services)
resource "google_compute_global_address" "services_private_ips" {
  name          = "services-private-ips"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.prefix_length
  network       = var.network_id
}

# Let create a peering connection to the service network
resource "google_service_networking_connection" "services_private" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.services_private_ips.name]
}

# Let's make sure we export and import routes to ensure connectivity
resource "google_compute_network_peering_routes_config" "services_private" {
  peering              = google_service_networking_connection.services_private.peering
  network              = var.network_name
  import_custom_routes = true
  export_custom_routes = true
}
