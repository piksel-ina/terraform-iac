output "account_id" {
  description = "AWS account ID this VPC is deployed in."
  value       = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "Primary VPC CIDR block."
  value       = module.vpc.vpc_cidr_block
}

output "azs" {
  description = "Availability Zones used."
  value       = module.vpc.azs
}

output "public_subnets" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnets
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  value       = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnets
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks."
  value       = module.vpc.private_subnets_cidr_blocks
}

output "nat_public_ips" {
  description = "NAT gateway public IPs."
  value       = module.vpc.nat_public_ips
}

output "public_route_table_ids" {
  description = "Public route table IDs."
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "Private route table IDs."
  value       = module.vpc.private_route_table_ids
}
