variable "project_name"        { type = string }
variable "environment"          { type = string }
variable "vpc_id"               { type = string }
variable "availability_zones"   { type = list(string) }
variable "public_subnet_cidrs"  { type = list(string) }
variable "private_app_cidrs"    { type = list(string) }
variable "private_db_cidrs"     { type = list(string) }
