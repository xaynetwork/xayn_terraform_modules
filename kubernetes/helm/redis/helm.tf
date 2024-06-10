resource "helm_release" "this" {
  name = var.name

  chart   = "oci://registry-1.docker.io/bitnamicharts/redis"
  version = "19.5.2"

  atomic           = true
  create_namespace = false
  namespace        = var.namespace

  set {
    name  = "auth.existingSecret"
    value = var.secret_name
  }

  set {
    name  = "auth.existingSecretPasswordKey"
    value = var.secret_key_name
  }

  values = [
    var.values
  ]
}
