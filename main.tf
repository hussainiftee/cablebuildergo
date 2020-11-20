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
  db_subnet_id       = module.networking.db_private_subnets
}
