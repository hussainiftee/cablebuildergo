

# -- Compute/output ---
output "Tomcat-Home-Page" {
  value = module.compute.alb_dns_name
}

output "CablebuilderGo-Login-Page" {
  value = "${module.compute.alb_dns_name}/context/servlet/em.cabbench.CabBenchSrv?requestType=logOn&xsl=login.xsl"
}

# -- Database Output ---

output "MySQL-RDS-EndPoint" {
  value = module.mysqlrds.rds-endpoint
}

/*output "MySQL-RDS-Address" {
  value = module.mysqlrds.rds-address
}


# -- IAM Output ---
output "IAM-Instance-Profile" {
  value = module.iam.instance_profile_name
}

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
*/