variable "vpc_id"{}

variable "db_subnet_id" {
  type = "list"
}

variable "db_sg_id"{}

variable "db_avail_zone" {}
variable "rds_instance_identifier" {}
variable "database_name" {}
variable "database_user" {}
variable "database_password" {}