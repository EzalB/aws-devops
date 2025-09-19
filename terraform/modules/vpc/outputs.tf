output "vpc_id" {
  value = aws_vpc.vpc_network.id
  description = "VPC id"
}

output "public_subnets" {
  value = aws_subnet.public[*].id
  description = "List of public subnet IDs"
}

output "private_subnets" {
  value = aws_subnet.private[*].id
  description = "List of private subnet IDs"
}
