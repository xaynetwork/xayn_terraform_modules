output "nlb_vpc_link_id" {
  value       = aws_api_gateway_vpc_link.this.id
  description = "The network loadbalancer vpc link id"
}
