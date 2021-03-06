# -----
# --- Compute Variable.
# -----
variable "acm_domain_name" {}

variable "ec2_key_name"{
  default = ""
}
variable "ec2_name_tag" {}
variable "app_sg_id" {}
variable "elb_sg_id" {}
variable "image_id" {}
variable "asg_instance_type" {}
variable "asg_vol_size" {}
variable "asg_vol_type" {}
variable "iam_instance_profile" {}
variable "rds_address" {}
variable "aws_region" {}
variable "alb_name" {}

variable "asg_min_size" {}
variable "asg_max_size" {}
variable "asg_desired_size" {}

variable "app_subnet_id" {
  type = "list"
}
variable "elb_subnet_id" {
  type = "list"
}

variable "vpc_id" {}

variable "tag_proj_name" {}
variable "tag_env" {}

# ----- End.  