output "nlb_vpc_link_id" {
  value       = aws_api_gateway_vpc_link.this.id
  description = "The network load balancer vpc link id"
}
