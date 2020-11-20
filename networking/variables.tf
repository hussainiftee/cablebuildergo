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
