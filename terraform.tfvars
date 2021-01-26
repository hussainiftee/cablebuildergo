# -----
# --- Terraform.tfvars.   
# ----- We need to update the below parameter as per our build requirements. amd then run 
# export AWS_SHARED_CREDENTIALS_FILE=/home/ec2-user/environment/cablebuildergo/creds
# cd /home/ec2-user/environment/cablebuildergo ; terraforom plan; terraform apply
# -----

# AWS Regions
aws_region = "eu-west-2"    // Launching All the resources in this ZONE
account_id = "102342825506" // Required for the IAM Policy to grant this account id

# Tagging 
tag_proj_name = "CableBuilderGo"
tag_env       = "Production"

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

# Compute Parameter for ASG and its ec2 machine
//image_id  is for Amazon Linux 2 AMI. It would be different in each region. Hence need to modify accordingly.
// e.g.  eu-west-1 = "ami-0ce1e3f77cd41957e" , eu-west-2 = "ami-0e80a462ede03e653"
image_id          = "ami-0e80a462ede03e653" //eu-west-2
asg_instance_type = "t2.medium"
asg_vol_size      = "15"
asg_vol_type      = "gp2"
ec2_name_tag      = "CBG-Application-Server"
ec2_key_name      = "CableBuilderGo1"
alb_name          = "cablebuildergo"
acm_domain_name   = "gocablebuilder.com"

// AutoScaling Instance Size
asg_min_size     = "1"
asg_desired_size = "1"
asg_max_size     = "2"


# Cloudtrail config 
s3_bucket_name               = "cablebuildergo-trail"
s3_bucket_days_to_expiration = "60"
s3_bucket_days_to_transition = "30"
multi_region_trail           = "false"

# VPC Flow Log
traffic_type = "ALL"


# Networking parameter should npt modify else it will recreate the cimplete infrastructure.
# Networking parameter
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

# ----- End.  