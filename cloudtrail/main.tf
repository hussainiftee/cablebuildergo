#
# CloudTrail Main module: Enable Cloud Trail and securing with KMS
#
/*
# Creating KMS key to secure the cloudtrail for security
resource "aws_kms_key" "logs" {
  description = "KMS Key used for log encryption"
  enable_key_rotation = true
   policy = <<POLICY
{
   "Version": "2012-10-17",
    "Id": "Key policy created by CloudTrail",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.account_id}:user/CimteqAdmin",
                    "arn:aws:iam::${var.account_id}:root"
                ]
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow CloudTrail to encrypt logs",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:GenerateDataKey*",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${var.account_id}:trail/*"
                }
            }
        },
        {
            "Sid": "Allow CloudTrail to describe key",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:DescribeKey",
            "Resource": "*"
        },
        {
            "Sid": "Allow principals in the account to decrypt log files",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${var.account_id}"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${var.account_id}:trail/*"
                }
            }
        },
        {
            "Sid": "Allow alias creation during setup",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "kms:CreateAlias",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${var.account_id}",
                    "kms:ViaService": "ec2.${var.aws_region}.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Enable cross account log decryption",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${var.account_id}"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${var.account_id}:trail/*"
                }
            }
        }
    ]
}
POLICY
tags = {
    Project        = var.tag_proj_name
    Environment = var.tag_env
  } 
}

resource "aws_kms_alias" "auditlog" {
    name = "alias/auditlog"
    target_key_id = aws_kms_key.logs.key_id
} 
*/

# Creating and Configuring CloudTrail
resource "aws_cloudtrail" "trail" {
  //name           = "trail${replace(title(var.tag_proj_name), " ", "")}${title(var.tag_env)}"
  name  = "trail${var.tag_proj_name}"
  s3_bucket_name = "${var.s3_bucket_name}"
  s3_key_prefix  = "${var.s3_key_prefix}"
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = "${var.multi_region_trail}"
  enable_log_file_validation    = true
  is_organization_trail         = "${var.organization_trail}"
  //kms_key_id                    = aws_kms_alias.auditlog.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

  data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
  
  tags = {
    Project        = var.tag_proj_name
    Environment = var.tag_env
  } 

  depends_on = ["aws_s3_bucket.trail"]
  
   /*lifecycle {
    ignore_changes = ["kms_key_id"]
  }*/
  
}

#Creating S3 bucket for Cloudtrail
resource "aws_s3_bucket" "trail" {

  bucket = var.s3_bucket_name
  force_destroy = true
  //region = var.aws_region

  lifecycle_rule {
    enabled = true

    transition {
      days          = "${var.s3_bucket_days_to_transition}"
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = "${var.s3_bucket_days_to_expiration}"
    }
  }
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY

tags = {
    Project        = var.tag_proj_name
    Environment = var.tag_env
  } 
}