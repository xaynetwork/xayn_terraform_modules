locals {
  helm_values = var.config_file
}

resource "kubernetes_namespace" "this" {
  count = var.namespace_name != null ? 1 : 0
  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "kong" {
  repository = var.repository_name
  chart      = var.name
  version    = var.chart_version

  name      = var.name
  namespace = var.namespace_name == null ? var.namespace_name : kubernetes_namespace.this.metadata[0].name

  values = [
    local.helm_values
  ]
}
