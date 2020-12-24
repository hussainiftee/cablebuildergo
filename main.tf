# Master Module to build 3 Tier Application with High Availaibility 
# Terraform and Provider Version mentioned in version.tf file

# AWS Provider information
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Deploy Networking Resource (VPC & Components)
module "networking" {
  source            = "./networking"
  vpc_cidr          = var.vpc_cidr
  dmz_public_cidrs  = var.dmz_public_cidrs
  app_private_cidrs = var.app_private_cidrs
  db_private_cidrs  = var.db_private_cidrs
  project_code      = var.project_code
}

# Deploy VPC Flow log
module "flowlog" {
  source = "./flowlog"
  vpc_id = module.networking.vpc_id
}

# Deploy CloudTrail
module "cloudtrail" {
  source         = "./cloudtrail"
  s3_bucket_name = var.s3_bucket_name
}

# Deploy Securtity (SG & NACL) Resource
module "security" {
  source           = "./security"
  vpc_cidr         = var.vpc_cidr
  ALB_IngCIDRblock = var.ALB_IngCIDRblock
  vpc_id           = module.networking.vpc_id
  dmz_subnet_id    = module.networking.public_subnets
  app_subnet_id    = module.networking.app_private_subnets
  db_subnet_id     = module.networking.db_private_subnets
}

# Deploy MySQL RDS Resource using RDS Snapshot
module "mysqlrds" {
  source = "./mysqlrds"
  //database_name    = var.database_name  (Not Required as using Snapshot)
  //database_user           = var.database_user (Not Required as using Snapshot)
  db_name_snapshot                = var.db_name_snapshot
  database_password               = var.database_password
  engine                          = var.engine
  engine_version                  = var.engine_version
  mysql_family                    = var.mysql_family
  storage_type                    = var.storage_type
  db_avail_zone                   = var.db_avail_zone
  rds_instance_identifier         = var.rds_instance_identifier
  db_instance_type                = var.db_instance_type
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  vpc_id                          = module.networking.vpc_id
  db_subnet_id                    = module.networking.db_private_subnets
  db_sg_id                        = module.security.db_sg_id
}


# Deploy IAM role and profile
module "iam" {
  source         = "./iam"
  aws_region     = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}


# Deploy Compute: ELB & ASG & EC2
module "compute" {
  source               = "./compute"
  image_id             = var.image_id
  asg_instance_type    = var.asg_instance_type
  asg_vol_size         = var.asg_vol_size
  asg_vol_type         = var.asg_vol_type
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  vpc_id               = module.networking.vpc_id
  elb_sg_id            = module.security.elb_sg_id
  app_sg_id            = module.security.app_sg_id
  app_subnet_id        = module.networking.app_private_subnets
  elb_subnet_id        = module.networking.public_subnets
  iam_instance_profile = module.iam.instance_profile_name
  rds_address          = module.mysqlrds.rds-address
  rds_password         = module.mysqlrds.rds-password
}


