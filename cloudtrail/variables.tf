#
# CloudTrail variable module: 
#

variable "tag_proj_name" {
  default     = "cimteq"
}

variable "tag_env" {
  default     = "Test"
}

variable "aws_region" {}

variable "account_id" {
  description = "Account Id"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store logs in (required)."
}

variable "s3_bucket_days_to_expiration" {
  default     = "60"
  description = "How many days to store logs before they will be deleted. Only applies if `enable_s3_bucket_expiration` is true."
}

variable "s3_bucket_days_to_transition" {
  default     = "30"
  description = "How many days to store logs before they will be transitioned to a new storage class. Only applies if `enable_s3_bucket_transition` is true."
}

variable "multi_region_trail" {
  default     = "false"
  description = "Specifies whether the trail is created in the current region or in all regions."
}

variable "organization_trail" {
  default     = "false"
  description = "Specifies whether the trail is an AWS Organizations trail, which must be created in the organization master account."
}

variable "s3_key_prefix" {
  default     = "cloudtrail"
  description = "Specifies the S3 key prefix that precedes the name of the bucket you have designated for log file delivery."
}