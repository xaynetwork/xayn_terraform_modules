output "username" {
  description = "Username of item"
  value       = data.onepassword_item.item.username
  sensitive   = false
}

output "password" {
  description = "Password of item"
  value       = data.onepassword_item.item.password
  sensitive   = true
}
