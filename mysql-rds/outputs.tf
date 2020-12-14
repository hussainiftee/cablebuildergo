output "rds-address" {
  value = aws_db_instance.default.address
}

output "rds-endpoint" {
  value = aws_db_instance.default.endpoint
}