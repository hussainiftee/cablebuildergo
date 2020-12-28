# AWS Configuration 
variable "aws_region" {
  description = "AWS region"
}

variable "aws_access_key" {
  description = "AWS Access Key - needed for IAM"
}

variable "aws_secret_key" {
  description = "AWS Secret Key- needed for IAM"
}

variable "account_id" {
  description = "AWS account_id needed for Key Policy"
}

#----networking/variables.tf

variable "project_code" {
  description = "Track the cost"
}

variable "vpc_cidr" {}

variable "dmz_public_cidrs" {
  type = "list"
}

variable "app_private_cidrs" {
  type = "list"
}

variable "db_private_cidrs" {
  type = "list"
}

#----security/variables.tf

variable "ALB_IngCIDRblock" {
  description = "Mention the specific IP range"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

#----database/variables.tf

variable "rds_instance_identifier" {}
//variable "database_name" {}
variable "db_name_snapshot" {}
//variable "database_user" {}
variable "database_password" {}
variable "db_avail_zone" {}
variable "engine_version" {}
variable "mysql_family" {}
variable "db_instance_type" {}
variable "allocated_storage" {}
variable "max_allocated_storage" {}
variable "storage_type" {}
variable "engine" {}
variable "enabled_cloudwatch_logs_exports" {
  type = "list"
}

#----compute/variables.tf
variable "image_id" {}
variable "asg_instance_type" {}
variable "asg_vol_size" {}
variable "asg_vol_type" {}
variable "asg_min_size" {}
variable "asg_max_size" {}

# Deploy VPC Flow log


# Deploy CloudTrail
variable "s3_bucket_name" {}