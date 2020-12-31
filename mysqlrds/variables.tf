# mysqlrds varriables
variable "vpc_id"{}

variable "db_subnet_id" {
  type = "list"
}

variable "db_sg_id"{}

//variable "db_avail_zone" {}
variable "rds_instance_identifier" {}
//variable "database_name" {}
//variable "database_user" {}
//variable "database_password" {}
variable "engine_version" {}
variable "mysql_family" {}
variable "db_instance_type" {}
variable "allocated_storage" {}
variable "max_allocated_storage" {}
variable "storage_type" {}
variable "engine" {}
variable "db_name_snapshot" {}

variable "enabled_cloudwatch_logs_exports" {
    type = "list"
}

variable "tag_proj_name" {
  default     = "cimteq"
}

variable "tag_env" {
  default     = "Test"
}