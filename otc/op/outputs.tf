output "access_key" {
  description = "The value of the access key for the user"
  value       = data.onepassword_item.ak.password
  sensitive   = true
}

output "secret_key" {
  description = "The value of the access key for the user"
  value       = data.onepassword_item.sk.password
  sensitive   = true
}
