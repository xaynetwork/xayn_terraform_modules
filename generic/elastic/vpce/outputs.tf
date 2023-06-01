output "vpce_id" {
  description = "The ID of the Elastic Cloud VPC endpoint"
  value       = aws_vpc_endpoint.elastic_cloud.id
}
