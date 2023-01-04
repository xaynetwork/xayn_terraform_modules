output "vpce_id" {
  description = "The ID of the Elasticsearch VPC endpoint"
  value       = aws_vpc_endpoint.elasticsearch.id
}
