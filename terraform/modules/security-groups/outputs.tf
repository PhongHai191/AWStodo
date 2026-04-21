output "alb_sg_id"        { value = aws_security_group.alb.id }
output "web_sg_id"        { value = aws_security_group.web.id }
output "bastion_sg_id"    { value = aws_security_group.bastion.id }
output "redis_sg_id"      { value = aws_security_group.redis.id }
output "rds_sg_id"        { value = aws_security_group.rds.id }
output "monitoring_sg_id" { value = aws_security_group.monitoring.id }
