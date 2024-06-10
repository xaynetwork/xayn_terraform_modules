resource "helm_release" "this" {
  name = var.name

  chart   = "oci://registry-1.docker.io/bitnamicharts/redis"
  version = "19.5.2"

  atomic           = true
  create_namespace = false
  namespace        = var.namespace

  values = [
    templatefile("${path.module}/values.yaml", {
      name            = var.name
      secret_key_name = var.secret_key_name
      secret_name     = var.secret_name
    })
  ]
}
