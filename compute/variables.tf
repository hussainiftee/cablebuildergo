variable "app_sg_id" {}
variable "elb_sg_id" {}
variable "image_id" {}
variable "asg_instance_type" {}
variable "iam_instance_profile" {}
variable "rds_address" {}

variable "app_subnet_id" {
  type = "list"
}
variable "elb_subnet_id" {
  type = "list"
}

variable "vpc_id" {}
