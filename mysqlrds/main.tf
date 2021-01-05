# -----
# RDS Main Module - MySQL RDS 
# -----

# As its NOT a MultiAZ RDS hence we need to mention in which AZ we want this RDS to get created.
data "aws_availability_zones" "availaible" {}

# RDS db private subnet 
resource "aws_db_subnet_group" "rdssg" {
  name        = "${var.rds_instance_identifier}-subnet-group"
  description = "AWS RDS subnet group"
  subnet_ids  =  var.db_subnet_id[*]
}


# Creating RDS Parameter Groups
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

# Creating Cloudwtach Log group for the RDS logs
resource "aws_cloudwatch_log_group" "group" {
  count             = 3
  name              = "/aws/rds/instance/${var.rds_instance_identifier}/${element(var.enabled_cloudwatch_logs_exports, count.index)}"
  retention_in_days = "30"
   tags = {
    Project        = var.tag_proj_name
    Environment = var.tag_env
  } 
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

# Creating the database from Snapshot, hence few parameters not required.
resource "aws_db_instance" "cbgrds" {
  identifier                = var.rds_instance_identifier
  snapshot_identifier       = data.aws_db_snapshot.latest_cbg_snapshot.id
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  availability_zone       = data.aws_availability_zones.availaible.names[0]  // 0 means az-1, 1 means az-2 and so on.
  storage_type         =  var.storage_type
  engine                    = var.engine
  engine_version            = var.engine_version
  instance_class            = var.db_instance_type
  //name                      = var.database_name
  //username                  = var.database_user
  password                  = random_password.password.result
  db_subnet_group_name      = aws_db_subnet_group.rdssg.id
  vpc_security_group_ids    = [var.db_sg_id]
  skip_final_snapshot       = true
  final_snapshot_identifier = var.rds_instance_identifier
  deletion_protection = false
  publicly_accessible = false
  storage_encrypted = true
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  parameter_group_name = aws_db_parameter_group.param_group.name
  
  depends_on = ["aws_db_parameter_group.param_group", "aws_cloudwatch_log_group.group", "random_password.password"]

  lifecycle {
    ignore_changes = ["snapshot_identifier"]
  }
  
  tags = {
    Project        = var.tag_proj_name
    Environment = var.tag_env
  } 
}

# Creating random password for the RDS
resource "random_password" "password" {
  length = 10
  special = true
  min_special = 1
  override_special = "_%"
}

# Updating the RDS pasword in AWS SSM Parameter Store
resource "aws_ssm_parameter" "secret" {
  name        = "/production/${var.rds_instance_identifier}/password/admin"
  description = "${var.rds_instance_identifier} database password"
  type        = "SecureString"
  value       = random_password.password.result

 tags = {
    Project        = var.tag_proj_name
    Environment = var.tag_env
  } 
}


# Creating SSM Run Document for updating the password on ec2 Application Server
resource aws_ssm_document password_update {
  name          = "cbg_password_update"
  document_type = "Command"

  content = <<DOC
  {
   "schemaVersion": "2.2",
   "description": "Execute rds password update on Application Server",
   "parameters": {
      
   },
   "mainSteps": [
      {
         "action": "aws:runShellScript",
         "name": "ec2_password_update",
         "inputs": {
            "runCommand": [
               "sudo /opt/CableBuilderGo/password_update.sh"
            ]
         }
      }
   ]
}
DOC
 tags = {
    Project        = var.tag_proj_name
    Environment = var.tag_env
  } 
}

resource aws_ssm_association password_update {
  name = aws_ssm_document.password_update.name

  targets {
    key    = "tag:Name"
    values = ["CBG-Application-Server"]
  }

  depends_on = ["aws_ssm_parameter.secret"]
  
}


# ----- End.  