locals {
  gateway_config = var.gateway_config_yaml
  kong_values = templatefile("base.yaml", {
    gateway_config : local.gateway_config
  })
}

resource "kubernetes_namespace" "kong" {
  metadata {
    name = "kong"
  }
}

resource "helm_release" "kong" {
  repository = "https://charts.konghq.com"
  chart      = "ingress"
  version    = trimprefix(var.chart_version, "v")

  name      = "kong"
  namespace = kubernetes_namespace.kong.metadata[0].name

  values = [
    local.kong_values
  ]
}
