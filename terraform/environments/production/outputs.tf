output "vpc_id"                  { value = module.network.vpc_id }
output "public_subnet_ids"       { value = module.network.public_subnet_ids }
output "private_app_subnet_ids"  { value = module.network.private_app_subnet_ids }
output "private_db_subnet_ids"   { value = module.network.private_db_subnet_ids }
output "alb_dns_name"            { value = module.alb.alb_dns_name }
output "bastion_public_ip"       { value = module.ec2.bastion_public_ip }
output "web_server_private_ips"  { value = module.ec2.web_server_private_ips }
output "redis_endpoint"          { value = module.redis.redis_endpoint }
output "rds_endpoint"            { 
    value = module.rds.rds_endpoint
    sensitive = true
}
output "s3_bucket_name"          { value = module.s3.bucket_name }
output "github_actions_role_arn" { value = module.iam.github_actions_role_arn }
output "rds_kms_key_arn"         { value = module.kms.rds_kms_key_arn }
output "secrets_kms_key_arn"     { value = module.kms.secrets_kms_key_arn }
output "bastion_key_secret_arn"  { value = module.ec2.bastion_key_secret_arn }
output "web_key_secret_arns"     { value = module.ec2.web_key_secret_arns }
output "db_credentials_secret_arn" { value = module.rds.db_credentials_secret_arn }
