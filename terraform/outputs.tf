output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.subnets.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of private app subnets"
  value       = module.subnets.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of private DB subnets"
  value       = module.subnets.private_db_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion host"
  value       = module.ec2.bastion_public_ip
}

output "web_server_private_ips" {
  description = "Private IPs of web server instances"
  value       = module.ec2.web_server_private_ips
}

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = module.redis.redis_endpoint
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = module.iam.github_actions_role_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.iam.ec2_instance_profile_name
}
