output "vpc_id" {
  description = "Landing zone VPC id."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block. Check this against your simulated on-premises range for overlap."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet ids. Use the first of these as the MGN staging subnet."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "Private subnet ids. Database tier."
  value       = [for s in aws_subnet.private : s.id]
}

output "mgn_staging_subnet_id" {
  description = "Subnet id to enter in the MGN replication settings template."
  value       = values(aws_subnet.public)[0].id
}

output "mgn_staging_sg_id" {
  description = "Security group id to enter in the MGN replication settings template."
  value       = aws_security_group.mgn_staging.id
}

output "app_sg_id" {
  description = "Security group for the migrated application server."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Security group for the migrated database server."
  value       = aws_security_group.db.id
}

output "dependency_sg_id" {
  description = "Security group for the supporting dependency server."
  value       = aws_security_group.dependency.id
}

output "availability_zones" {
  description = "AZs the subnets were placed in."
  value       = local.azs
}
