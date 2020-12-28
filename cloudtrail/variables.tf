variable "project" {
  default     = "cimteq"
  description = "Project name, used for tagging and naming the Trail."
}

variable "environment" {
  default     = "Test"
  description = "Name of the environment this Trail is targeting."
}

variable "aws_region" {
  default     = "eu-west-1"
  description = "Name of the region where the Trail should be created."
}

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

variable "is_multi_region_trail" {
  default     = "false"
  description = "Specifies whether the trail is created in the current region or in all regions."
}

variable "is_organization_trail" {
  default     = "false"
  description = "Specifies whether the trail is an AWS Organizations trail, which must be created in the organization master account."
}

variable "s3_key_prefix" {
  default     = "cloudtrail"
  description = "Specifies the S3 key prefix that precedes the name of the bucket you have designated for log file delivery."
}