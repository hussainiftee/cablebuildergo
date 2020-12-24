# Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id      = var.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name = "DefaultSG"
  }
}


# Create Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  vpc_id      = var.vpc_id
  name        = "CBG-BastionSG"
  description = "Allow SSH from listed cidr blocks"

  # allow ingress of port 22
  ingress {
    cidr_blocks = [var.vpc_cidr]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "BastionSG"
  }
}

# Create Load Balancer Security Group
resource "aws_security_group" "elb_sg" {
  vpc_id      = var.vpc_id
  name        = "CBG-LoadBalancerSG"
  description = "All incoming connection allowed"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ALB_IngCIDRblock
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ALB_IngCIDRblock
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.ALB_IngCIDRblock
  }

  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "LoadBalancerSG"
  }
}


# Create Application Security Group
resource "aws_security_group" "app_sg" {
  vpc_id      = var.vpc_id
  name        = "CBG-ApplicationSG"
  description = "Incoming connection allowed from Bastion or ALB security Group"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ApplicationSG"
  }
}

# Create RDS Security Group
resource "aws_security_group" "db_sg" {
  vpc_id      = var.vpc_id
  name        = "CBG-DatabaseSG"
  description = "Allow Incoming connection from Application security Group"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app_sg.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "DatabaseSG"
  }
}

# Create Public NACL

resource "aws_network_acl" "dmz_public_acl" {
  vpc_id      = var.vpc_id
  subnet_ids = var.dmz_subnet_id[*]
  
  # allow ingress port SSH
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  # allow ingress port HTTP
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
   # allow ingress port HTTPS
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
   # allow ingress port for Tomcat
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 8080
    to_port    = 8080
  }
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
   # allow egress port SSH
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 22  
    to_port    = 22 
  }
 
   # allow egress port HTTP
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80  
    to_port    = 80 
  }
 
   # allow egress port HTTPS
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443  
    to_port    = 443 
  }
 
  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
  tags = {
    Name = "CBG_Public_NACL"
  }
}


# Create Private Application NACL

resource "aws_network_acl" "app_priv_acl" {
  vpc_id      = var.vpc_id
  subnet_ids = var.app_subnet_id[*]

# allow ingress port SSH
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 22
    to_port    = 22
  }
  
  # allow ingress port HTTP
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 80
    to_port    = 80
  }
  
   # allow ingress port HTTPS
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 443
    to_port    = 443
  }
  
   # allow ingress port Tomcat
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 8080
    to_port    = 8080
  }
  
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
   # allow egress port HTTP (Need for Session Manager)
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80  
    to_port    = 80 
  }
 
   # allow egress port HTTPS (Need for Session Manager)
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443  
    to_port    = 443 
  }
  
  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
  tags = {
    Name = "CBG_App_Priv_NACL"
  }
}

# Create Private Database NACL

resource "aws_network_acl" "db_priv_acl" {
  vpc_id      = var.vpc_id
  subnet_ids = var.db_subnet_id[*]
  
 # allow ingress port MySQL RDS
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 3306
    to_port    = 3306
  }
 
  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }
  
  tags = {
    Name = "CBG_DB_Priv_NACL"
  }
}

