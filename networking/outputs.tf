# -----
# --- Networking Output Module.
# -----

#---- Mandate: Use for refernce
output "vpc_id" {
  value = aws_vpc.cbg_vpc.id
}

#---- Optional: Display Only
output "public_subnets" {
  value = aws_subnet.tf_public_subnet.*.id
}

output "public_subnet_ips" {
  value = aws_subnet.tf_public_subnet.*.cidr_block
}

output "app_private_subnets" {
  value = aws_subnet.tf_app_private_subnet.*.id
}

output "app_private_ips" {
  value = aws_subnet.tf_app_private_subnet.*.cidr_block
}

output "db_private_subnets" {
  value = aws_subnet.tf_db_private_subnet.*.id
}

output "db_private_ips" {
  value = aws_subnet.tf_db_private_subnet.*.cidr_block
}

# ----- End.  