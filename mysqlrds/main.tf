# RDS Module - MySQL

resource "aws_db_subnet_group" "rdssg" {
  name        = "${var.rds_instance_identifier}-subnet-group"
  description = "AWS RDS subnet group"
  subnet_ids  =  var.db_subnet_id[*]
}

resource "aws_db_parameter_group" "param_group" {
  name        = "cbg-rds-mysql8"
  description = "Parameter group for Mysql8.0"
  family      = var.mysql_family
  parameter {
    name  = "character_set_server"
    value = "utf8"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "lower_case_table_names"
    value = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "general_log"
    value = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "log_output"
    value = "FILE"
    apply_method = "pending-reboot"
  }
}

/*resource "aws_cloudwatch_log_group" "error" {
 name = "/aws/rds/instance/${var.rds_instance_identifier}/error"
 retention_in_days = "30"
}*/

resource "aws_cloudwatch_log_group" "group" {
  count             = 3
  name              = "/aws/rds/instance/${var.rds_instance_identifier}/${element(var.enabled_cloudwatch_logs_exports, count.index)}"
  retention_in_days = "30"
}

resource "aws_cloudwatch_log_stream" "stream" {
  count          = 3
  name           = "${var.rds_instance_identifier}"
  log_group_name = "${element(aws_cloudwatch_log_group.group.*.name, count.index)}"
} 

data "aws_db_snapshot" "latest_cbg_snapshot" {
  db_instance_identifier = var.db_name_snapshot
  most_recent            = true
}

# Creating the database from Snapshot, hence few parameter commented.
resource "aws_db_instance" "cbgrds" {
  identifier                = var.rds_instance_identifier
  snapshot_identifier       = data.aws_db_snapshot.latest_cbg_snapshot.id
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  availability_zone     = var.db_avail_zone
  storage_type         =  var.storage_type
  engine                    = var.engine
  engine_version            = var.engine_version
  instance_class            = var.db_instance_type
  //name                      = var.database_name
  //username                  = var.database_user
  password                  = var.database_password
  db_subnet_group_name      = aws_db_subnet_group.rdssg.id
  vpc_security_group_ids    = [var.db_sg_id]
  skip_final_snapshot       = true
  final_snapshot_identifier = "CodeBuilderGo-v1"
  deletion_protection = false
  publicly_accessible = false
  storage_encrypted = true
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  parameter_group_name = aws_db_parameter_group.param_group.name
  
  depends_on = ["aws_db_parameter_group.param_group", "aws_cloudwatch_log_group.group"]

  lifecycle {
    ignore_changes = ["snapshot_identifier"]
  }
}