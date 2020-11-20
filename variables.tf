variable "aws_region" {
  description = "AWS region"
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

variable "bastionIngCIDRblock" {
  description = "Mention the specific IP range"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

variable "ALB_IngCIDRblock" {
  description = "Mention the specific IP range"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

#----database/variables.tf

variable "rds_instance_identifier" {}
variable "database_name" {}
variable "database_user" {}
variable "database_password" {}
variable "db_avail_zone" {}