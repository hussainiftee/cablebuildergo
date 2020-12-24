output "rds-address" {
  value = aws_db_instance.cbgrds.address
}

output "rds-endpoint" {
  value = aws_db_instance.cbgrds.endpoint
}

output "rds-password" {
  value = aws_db_instance.cbgrds.password
}