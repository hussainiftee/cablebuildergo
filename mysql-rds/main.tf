resource "aws_db_subnet_group" "default" {
  name        = "${var.rds_instance_identifier}-subnet-group"
  description = "AWS RDS subnet group"
  subnet_ids  =  var.db_subnet_id[*]
}

resource "aws_db_instance" "default" {
  identifier                = var.rds_instance_identifier
  allocated_storage     = 50
  max_allocated_storage = 100
  availability_zone     = var.db_avail_zone
  storage_type         = "gp2"
  engine                    = "mysql"
  engine_version            = "8.0.17"
  instance_class            = "db.t2.micro"
  name                      = var.database_name
  username                  = var.database_user
  password                  = var.database_password
  db_subnet_group_name      = aws_db_subnet_group.default.id
  vpc_security_group_ids    = [var.db_sg_id]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
  deletion_protection = false
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  parameter_group_name = aws_db_parameter_group.default.name
}

resource "aws_db_parameter_group" "default" {
  name        = "${var.rds_instance_identifier}-param-group-Mysql8.0"
  description = "Parameter group for Mysql8.0"
  family      = "mysql8.0"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_cloudwatch_log_group" "error" {
  name = "/aws/rds/instance/${aws_db_instance.default.identifier}/error"
  retention_in_days = "5"
}