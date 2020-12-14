provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
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

# Deploy Securtity (Sg & NACL) Resource
module "security" {
  source           = "./security"
  ALB_IngCIDRblock = var.ALB_IngCIDRblock
  vpc_id           = module.networking.vpc_id
  vpc_cidr         = var.vpc_cidr
  dmz_subnet_id    = module.networking.public_subnets
  app_subnet_id    = module.networking.app_private_subnets
  db_subnet_id     = module.networking.db_private_subnets
}

# Deploy MySQL RDS Resource
module "mysql-rds" {
  source = "./mysql-rds"
  //database_name    = var.database_name
  db_name_snapshot = var.db_name_snapshot
  //database_user           = var.database_user
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
  vpc_id                  = module.networking.vpc_id
  db_subnet_id            = module.networking.db_private_subnets
  db_sg_id                = module.security.db_sg_id
}


# Deploy Compute: ELB & ASG & EC2
module "iam" {
  source         = "./iam"
  aws_region     = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}


# Deploy Compute: ELB & ASG & EC2
module "compute" {
  source = "./compute"
  vpc_id = module.networking.vpc_id
  //db_sg_id             = module.security.db_sg_id
  elb_sg_id     = module.security.elb_sg_id
  app_sg_id     = module.security.app_sg_id
  app_subnet_id = module.networking.app_private_subnets
  //db_subnet_id         = module.networking.db_private_subnets
  elb_subnet_id        = module.networking.public_subnets
  iam_instance_profile = module.iam.instance_profile_name
  image_id             = var.image_id
  asg_instance_type    = var.asg_instance_type
  rds_address          = module.mysql-rds.rds-address
} 