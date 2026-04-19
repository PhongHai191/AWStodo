# ── Public Subnets ──────────────────────────────────────────────────────────
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    Tier = "public"
  }
}

# ── Private App Subnets ──────────────────────────────────────────────────────
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_app_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-app-${count.index + 1}"
    Tier = "private-app"
  }
}

# ── Private DB Subnets ────────────────────────────────────────────────────────
resource "aws_subnet" "private_db" {
  count             = length(var.private_db_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_db_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-db-${count.index + 1}"
    Tier = "private-db"
  }
}
