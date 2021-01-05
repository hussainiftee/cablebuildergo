# -----
# --- Networking Variable Module.
# ----- 

variable "tag_proj_name" {
  default     = "cimteq"
}

variable "tag_env" {
  default     = "Test"
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

# ----- End.  