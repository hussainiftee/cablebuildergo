# AWS Regions
aws_region = "eu-west-2"    // Launching All the resources in this ZONE
account_id = "102342825506" // Required for the IAM Policy to grant this account id

# Tagging 
tag_proj_name = "CableBuilderGo"
tag_env       = "Production"

# Networking 
//project_code = "CodeBuilderGo"
vpc_cidr = "10.99.0.0/16"
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
rds_instance_identifier = "cablebuildergo"
//database_name           = "cbg"
//database_user           = "admin"
engine_version        = "8.0.20"
mysql_family          = "mysql8.0"
db_instance_type      = "db.m5.large"
allocated_storage     = "50"
max_allocated_storage = "100"
storage_type          = "gp2"
db_name_snapshot      = "cablebuildergo"
enabled_cloudwatch_logs_exports = [
  "error",
  "general",
  "slowquery"
]

# Compute Parameter
//image_id          = "ami-0ce1e3f77cd41957e" //eu-west-1
image_id          = "ami-0e80a462ede03e653" //eu-west-2
asg_instance_type = "t2.medium"
asg_vol_size      = "15"
asg_vol_type      = "gp2"

// AutoScaling Instance Size
asg_min_size = "1"
asg_max_size = "1"


# Cloudtrail config variables
s3_bucket_name               = "cablebuildergo-trail"
s3_bucket_days_to_expiration = "60"
s3_bucket_days_to_transition = "30"
multi_region_trail           = "false"