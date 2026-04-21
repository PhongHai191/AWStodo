# ── Security Group Definitions (no inline rules) ──────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.project_name}-${var.environment}-alb-sg" }
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Security group for web server EC2 instances"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.project_name}-${var.environment}-web-sg" }
}

resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-${var.environment}-bastion-sg"
  description = "Security group for the Bastion host"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.project_name}-${var.environment}-bastion-sg" }
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-${var.environment}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.project_name}-${var.environment}-redis-sg" }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.project_name}-${var.environment}-rds-sg" }
}

# ── ALB Rules ─────────────────────────────────────────────────────────────────
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  description       = "HTTP from internet"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  description       = "HTTPS from internet"
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_web_80" {
  type                     = "egress"
  description              = "To web servers on port 80"
  security_group_id        = aws_security_group.alb.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "alb_egress_web_3000" {
  type                     = "egress"
  description              = "To web servers on port 3000"
  security_group_id        = aws_security_group.alb.id
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

# ── Web Server Rules ──────────────────────────────────────────────────────────
resource "aws_security_group_rule" "web_ingress_alb_80" {
  type                     = "ingress"
  description              = "HTTP from ALB"
  security_group_id        = aws_security_group.web.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "web_ingress_alb_3000" {
  type                     = "ingress"
  description              = "App port from ALB"
  security_group_id        = aws_security_group.web.id
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "web_ingress_bastion_ssh" {
  type                     = "ingress"
  description              = "SSH from Bastion"
  security_group_id        = aws_security_group.web.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "web_egress_redis" {
  type                     = "egress"
  description              = "Redis outbound"
  security_group_id        = aws_security_group.web.id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "web_egress_rds" {
  type                     = "egress"
  description              = "RDS outbound"
  security_group_id        = aws_security_group.web.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "web_egress_https" {
  type              = "egress"
  description       = "HTTPS outbound (S3, SSM, etc.)"
  security_group_id = aws_security_group.web.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_egress_http" {
  type              = "egress"
  description       = "HTTP outbound (package updates)"
  security_group_id = aws_security_group.web.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ── Bastion Rules ─────────────────────────────────────────────────────────────
resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  description       = "SSH from trusted IP only"
  security_group_id = aws_security_group.bastion.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.trusted_ip]
}

resource "aws_security_group_rule" "bastion_egress_ssh" {
  type                     = "egress"
  description              = "SSH to web servers"
  security_group_id        = aws_security_group.bastion.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

# ── Redis Rules ───────────────────────────────────────────────────────────────
resource "aws_security_group_rule" "redis_ingress_web" {
  type                     = "ingress"
  description              = "Redis from web servers"
  security_group_id        = aws_security_group.redis.id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

# ── RDS Rules ─────────────────────────────────────────────────────────────────
resource "aws_security_group_rule" "rds_ingress_web" {
  type                     = "ingress"
  description              = "PostgreSQL from web servers"
  security_group_id        = aws_security_group.rds.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "rds_ingress_monitoring" {
  type                     = "ingress"
  description              = "PostgreSQL from monitoring (postgres_exporter)"
  security_group_id        = aws_security_group.rds.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id
}

# ── Monitoring SG ─────────────────────────────────────────────────────────────
resource "aws_security_group" "monitoring" {
  name        = "${var.project_name}-${var.environment}-monitoring-sg"
  description = "Security group for monitoring EC2 (Prometheus + Grafana)"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.project_name}-${var.environment}-monitoring-sg" }
}

resource "aws_security_group_rule" "monitoring_ingress_grafana" {
  type              = "ingress"
  description       = "Grafana from trusted IP"
  security_group_id = aws_security_group.monitoring.id
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = [var.trusted_ip]
}

resource "aws_security_group_rule" "monitoring_egress_node_exporter" {
  type                     = "egress"
  description              = "Scrape node_exporter on web servers"
  security_group_id        = aws_security_group.monitoring.id
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "monitoring_egress_cadvisor" {
  type                     = "egress"
  description              = "Scrape cadvisor on web servers"
  security_group_id        = aws_security_group.monitoring.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "monitoring_egress_app_metrics" {
  type                     = "egress"
  description              = "Scrape /metrics on web servers"
  security_group_id        = aws_security_group.monitoring.id
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "monitoring_egress_redis" {
  type                     = "egress"
  description              = "redis_exporter to ElastiCache"
  security_group_id        = aws_security_group.monitoring.id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "monitoring_egress_rds" {
  type                     = "egress"
  description              = "postgres_exporter to RDS"
  security_group_id        = aws_security_group.monitoring.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "monitoring_egress_https" {
  type              = "egress"
  description       = "HTTPS outbound (AWS APIs, SSM, ECR, Docker Hub)"
  security_group_id = aws_security_group.monitoring.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "monitoring_egress_http" {
  type              = "egress"
  description       = "HTTP outbound (package updates)"
  security_group_id = aws_security_group.monitoring.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ── Web SG — allow scraping from monitoring ───────────────────────────────────
resource "aws_security_group_rule" "web_ingress_monitoring_node_exporter" {
  type                     = "ingress"
  description              = "node_exporter from monitoring"
  security_group_id        = aws_security_group.web.id
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "web_ingress_monitoring_cadvisor" {
  type                     = "ingress"
  description              = "cadvisor from monitoring"
  security_group_id        = aws_security_group.web.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "web_ingress_monitoring_metrics" {
  type                     = "ingress"
  description              = "App /metrics from monitoring"
  security_group_id        = aws_security_group.web.id
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id
}

# ── Redis SG — allow from monitoring ─────────────────────────────────────────
resource "aws_security_group_rule" "redis_ingress_monitoring" {
  type                     = "ingress"
  description              = "Redis from monitoring (redis_exporter)"
  security_group_id        = aws_security_group.redis.id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id
}
