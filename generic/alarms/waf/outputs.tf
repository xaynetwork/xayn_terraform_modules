output "ids" {
  description = "IDs of the CloudWatch alarms."
  value = {
    all_requests         = try(module.all_requests.id, "")
    all_blocked_requests = try(module.all_blocked_requests.id, "")
    ip_rate_limit        = try(module.ip_rate_limit.id, "")
  }
}
