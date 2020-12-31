
# FlowLog varriable module.

variable "vpc_id" {}

variable "tag_proj_name" {
  default     = "cimteq"
}

variable "tag_env" {
  default     = "Test"
}

variable "traffic_type" {
  default = "ALL"
  description = "https://www.terraform.io/docs/providers/aws/r/flow_log.html#traffic_type"
}

// workaround for not being able to do interpolation in variable defaults
// https://github.com/hashicorp/terraform/issues/4084
locals {
  default_log_group_name = "${var.tag_proj_name}-flow-log"
}
variable "log_group_name" {
  default = ""
  description = "Defaults to `$${default_log_group_name}`"
}