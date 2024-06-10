resource "random_password" "password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "password" {
  metadata {
    name      = var.secret_name
    namespace = var.namespace
  }

  data = {
    (var.secret_key_name) = random_password.password.result
  }
}
