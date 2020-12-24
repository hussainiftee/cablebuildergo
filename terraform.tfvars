# AWS Settings
aws_region = "eu-west-1"

# Tagging or the Resource Cost


project_code = "CodeBuilderGo"
vpc_cidr     = "10.99.0.0/16"
dmz_public_cidrs = [
  "10.99.1.0/24",
  "10.99.2.0/24"
]
app_private_cidrs = [
  "10.99.11.0/24",
  "10.99.12.0/24"
]
db_private_cidrs = [
  "10.99.21.0/24",
  "10.99.22.0/24"
]

# MySQL RDS Database Parameter
engine                  = "mysql"
db_avail_zone           = "eu-west-1a"
rds_instance_identifier = "cablebuildergo"
//database_name           = "cbg"
//database_user           = "admin"
engine_version        = "8.0.20"
mysql_family          = "mysql8.0"
db_instance_type      = "db.m5.large"
allocated_storage     = "50"
max_allocated_storage = "100"
storage_type          = "gp2"
db_name_snapshot      = "cablebuildergo2"
enabled_cloudwatch_logs_exports = [
  "error",
  "general",
  "slowquery"
]

# Compute Parameter
image_id          = "ami-0ce1e3f77cd41957e"
asg_instance_type = "t2.medium"
asg_vol_size      = "15"
asg_vol_type      = "gp2"

// AutoScaling Instance Size
asg_min_size = "1"
asg_max_size = "2"


# Deploy VPC Flow log

# Deploy Cloudtrail
s3_bucket_name = "cablebuildergo-trail"