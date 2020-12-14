variable "vpc_id"{}

variable "vpc_cidr"{}

variable "dmz_subnet_id" {
  type = "list"
}

variable "app_subnet_id" {
  type = "list"
}

variable "db_subnet_id" {
  type = "list"
}

variable "ALB_IngCIDRblock" {
  description = "Mention the specific IP range"
  type        = "list"
  default     = ["0.0.0.0/0"]
}