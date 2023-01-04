output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "subnet_public_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "subnet_private_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "subnet_private_cidr_blocks" {
  description = "The CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}
