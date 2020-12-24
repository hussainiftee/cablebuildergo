# -- root/output ---

# -- Networking/output ---

output "CBG-Public-Subnets" {
  value = join(", ", module.networking.public_subnets)
}

output "CBG-Public-Subnet-IPs" {
  value = join(", ", module.networking.public_subnet_ips)
}

output "App-Private-Subnets" {
  value = join(", ", module.networking.app_private_subnets)
}

output "App-Private-Subnet-IPs" {
  value = join(", ", module.networking.app_private_ips)
}

output "DB-Private-Subnets" {
  value = join(", ", module.networking.db_private_subnets)
}

output "DB-Private-Subnet-IPs" {
  value = join(", ", module.networking.db_private_ips)
}

# -- Security/output ---

# -- Database Output ---
output "MySQL-RDS-Address" {
  value = module.mysqlrds.rds-address
}

output "MySQL-RDS-EndPoint" {
  value = module.mysqlrds.rds-endpoint
}

# -- IAM Output ---
output "IAM-Instance-Profile" {
  value = module.iam.instance_profile_name
}