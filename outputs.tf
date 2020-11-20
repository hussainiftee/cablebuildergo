# -- root/output ---

# -- Networking/output ---

output "DMZ-Public-Subnets" {
  value = join(", ", module.networking.public_subnets)
}

output "DMZ-Public-Subnet-IPs" {
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
