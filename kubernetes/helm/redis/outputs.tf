output "password" {
  sensitive = true
  value     = random_password.password.result
}
