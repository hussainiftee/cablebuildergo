variable "vpc_id"{}

variable "dmz_subnet_id" {
  type = "list"
}

variable "app_subnet_id" {
  type = "list"
}

variable "db_subnet_id" {
  type = "list"
}


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