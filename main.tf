provider "aws" {
  region = var.aws_region
}

# Deploy Networking Resource
module "networking" {
  source            = "./networking"
  vpc_cidr          = var.vpc_cidr
  dmz_public_cidrs  = var.dmz_public_cidrs
  app_private_cidrs = var.app_private_cidrs
  db_private_cidrs  = var.db_private_cidrs
  project_code      = var.project_code
}

# Deploy Networking Resource
module "security" {
  source              = "./security"
  bastionIngCIDRblock = var.bastionIngCIDRblock
  ALB_IngCIDRblock    = var.ALB_IngCIDRblock
  vpc_id              = module.networking.vpc_id
  dmz_subnet_id       = module.networking.public_subnets
  app_subnet_id       = module.networking.app_private_subnets
  db_subnet_id        = module.networking.db_private_subnets
}

# Deploy MySQL RDS Resource
module "mysql-rds" {
  source = "./mysql-rds"
  database_name           = var.database_name
  database_user           = var.database_user
  database_password       = var.database_password
  engine                  = var.engine
  engine_version          = var.engine_version
  mysql_family            = var.mysql_family
  storage_type            = var.storage_type
  db_avail_zone           = var.db_avail_zone
  rds_instance_identifier = var.rds_instance_identifier
  db_instance_type        = var.db_instance_type
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  db_name_snapshot    = var.db_name_snapshot
  vpc_id                  = module.networking.vpc_id
  db_subnet_id            = module.networking.db_private_subnets
  db_sg_id                = module.security.db_sg_id
}