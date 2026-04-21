terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "awstodo-terraform-state-529646246979"
    key            = "production/terraform.tfstate"
    region         = "ap-southeast-2"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ── KMS Keys ───────────────────────────────────────────────────────────────────
module "kms" {
  source       = "../../modules/kms"
  project_name = var.project_name
  environment  = var.environment
}


# ── Network (VPC + Subnets + IGW + NAT) ───────────────────────────────────────
module "network" {
  source               = "../../modules/network"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_app_cidrs    = var.private_app_cidrs
  private_db_cidrs     = var.private_db_cidrs
}

# ── Security Groups ────────────────────────────────────────────────────────────
module "security_groups" {
  source       = "../../modules/security-groups"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  trusted_ip   = var.trusted_ip
}

# ── WAF ────────────────────────────────────────────────────────────────────────
module "waf" {
  source       = "../../modules/waf"
  project_name = var.project_name
  environment  = var.environment
}

# ── ALB ────────────────────────────────────────────────────────────────────────
module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  waf_acl_arn       = module.waf.waf_acl_arn
}

# ── IAM ────────────────────────────────────────────────────────────────────────
module "iam" {
  source               = "../../modules/iam"
  project_name         = var.project_name
  environment          = var.environment
  s3_bucket_arn        = module.s3.bucket_arn
  github_repo          = var.github_repo
  secrets_kms_key_arn  = module.kms.secrets_kms_key_arn
}

# ── EC2 ────────────────────────────────────────────────────────────────────────
module "ec2" {
  source                    = "../../modules/ec2"
  project_name              = var.project_name
  environment               = var.environment
  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  kms_key_arn               = module.kms.secrets_kms_key_arn
  private_app_subnet_ids    = module.network.private_app_subnet_ids
  public_subnet_ids         = module.network.public_subnet_ids
  web_sg_id                 = module.security_groups.web_sg_id
  bastion_sg_id             = module.security_groups.bastion_sg_id
  ec2_instance_profile      = module.iam.ec2_instance_profile_name
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  backend_target_group_arn  = module.alb.backend_target_group_arn
}

# ── Redis ──────────────────────────────────────────────────────────────────────
module "redis" {
  source                 = "../../modules/redis"
  project_name           = var.project_name
  environment            = var.environment
  private_app_subnet_ids = module.network.private_app_subnet_ids
  redis_sg_id            = module.security_groups.redis_sg_id
}

# ── RDS ────────────────────────────────────────────────────────────────────────
module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  environment           = var.environment
  private_db_subnet_ids = module.network.private_db_subnet_ids
  rds_sg_id             = module.security_groups.rds_sg_id
  kms_key_arn           = module.kms.rds_kms_key_arn
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
  db_instance_class     = var.db_instance_class
}

# ── S3 ─────────────────────────────────────────────────────────────────────────
module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  environment  = var.environment
  bucket_name  = var.s3_bucket_name
}

# ── SSM Parameters ─────────────────────────────────────────────────────────────
module "ssm" {
  source         = "../../modules/ssm"
  environment    = var.environment
  kms_key_arn    = module.kms.secrets_kms_key_arn
  aws_region     = var.aws_region
  s3_bucket_name = var.s3_bucket_name

  db_host        = split(":", module.rds.rds_endpoint)[0]
  db_user        = var.db_username
  db_password    = var.db_password
  db_name        = var.db_name
  db_secret_name = "${var.project_name}/${var.environment}/db/credentials"

  redis_host = module.redis.redis_endpoint

  jwt_access_secret  = var.jwt_access_secret
  jwt_refresh_secret = var.jwt_refresh_secret
}
