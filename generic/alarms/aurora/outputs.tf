output "ids" {
  description = "IDs of the CloudWatch alarms."
  value = {
    read_latency  = try(module.read_latency.id, "")
    write_latency = try(module.write_latency.id, "")
  }
}
