aws_region   = "eu-west-1"
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

db_avail_zone           = "eu-west-1a"
rds_instance_identifier = "CableBuilderGo"
database_name           = "cbg"
database_user           = "cbgmaster"