# -----
# Main Master module Varriable information
# -----

#---- AWS Configuration 
variable "aws_region" {
  description = "AWS region"
}

variable "account_id" {
  description = "AWS account_id needed for Key Policy"
}


#----Tagging
variable "tag_proj_name" {}
variable "tag_env" {}

#----networking/variables.tf

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
variable "asg_desired_size" {}
variable "ec2_key_name" {
  default = ""
}
variable "ec2_name_tag" {}
variable "alb_name" {}
variable "acm_domain_name" {}

#---- FlowLog
variable "traffic_type" {}

#---- Deploy CloudTrail
variable "s3_bucket_name" {}
variable "s3_bucket_days_to_expiration" {}
variable "s3_bucket_days_to_transition" {}
variable "multi_region_trail" {}

# ----- End.  