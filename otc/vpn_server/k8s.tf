# create a k8s service with a hardcoded endpoint
# https://kubernetes.io/docs/concepts/services-networking/service/#services-without-selectors
resource "kubernetes_service" "peer" {
  for_each = {
    for peer in local.peers : peer.name => peer
  }

  metadata {
    name      = each.value.service_name
    namespace = var.namespace
  }
  spec {
    port {
      name        = "http"
      port        = var.service_port
      protocol    = "TCP"
      target_port = "http"
    }
  }
}

resource "kubernetes_endpoints" "peer" {
  for_each = {
    for peer in local.peers : peer.name => peer
  }

  metadata {
    name      = kubernetes_service.peer[each.key].metadata[0].name
    namespace = kubernetes_service.peer[each.key].metadata[0].namespace
  }
  subset {
    address {
      ip = opentelekomcloud_compute_instance_v2.this.access_ip_v4
    }
    port {
      name     = "http"
      port     = each.value.server_port
      protocol = "TCP"
    }
  }
}
