provider "aws" {
  region = var.aws_region
}

# declare a VPC
data "aws_availability_zones" "availaible" {}

resource "aws_vpc" "cbg_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "CableBuilderGoVPC"
    Project = "var.project_code"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "cbg_vpc_igw" {
  vpc_id = aws_vpc.cbg_vpc.id

  tags = {
    Name    = "CableBuilderGoIGW"
    Project = "var.project_code"
  }
}


# Creating Public Route Table
resource "aws_route_table" "tf_public_rt" {
  vpc_id = aws_vpc.cbg_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cbg_vpc_igw.id
  }

  tags = {
    Name = "PublicRT"
  }
}

# DMZ Public subnet with High Availaibility
resource "aws_subnet" "tf_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.cbg_vpc.id
  cidr_block              = var.dmz_public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.availaible.names[count.index]

  tags = {
    Name    = "DMZ_PUBLIC_${count.index + 1}"
    Project = "var.project_code"
  }
}

resource "aws_route_table_association" "tf_public_assoc" {
  count          = length(aws_subnet.tf_public_subnet)
  subnet_id      = aws_subnet.tf_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.tf_public_rt.id
}

# Creating Private Route Table
resource "aws_route_table" "tf_private_rt" {
  vpc_id = aws_vpc.cbg_vpc.id

  tags = {
    Name = "PrivateRT"
  }
}

# Application Private subnet with High Availaibility
resource "aws_subnet" "tf_app_private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.cbg_vpc.id
  cidr_block        = var.app_private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.availaible.names[count.index]

  tags = {
    Name    = "APP_PRIVATE_${count.index + 1}"
    Project = "var.project_code"
  }
}

resource "aws_route_table_association" "tf_app_private_assoc" {
  count          = length(aws_subnet.tf_app_private_subnet)
  subnet_id      = aws_subnet.tf_app_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.tf_private_rt.id
}

# Database Private subnet with High Availaibility
resource "aws_subnet" "tf_db_private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.cbg_vpc.id
  cidr_block        = var.db_private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.availaible.names[count.index]

  tags = {
    Name    = "DB_PRIVATE_${count.index + 1}"
    Project = "var.project_code"
  }
}

resource "aws_route_table_association" "tf_db_private_assoc" {
  count          = length(aws_subnet.tf_db_private_subnet)
  subnet_id      = aws_subnet.tf_db_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.tf_private_rt.id
}

#  EIP for NAT Gateway
resource "aws_eip" "nat_gw_eip" {
  vpc = true

  tags = {
    Name    = "CableBuilder-NGW-EIP"
    Project = "var.project_code"
  }
}

# NAT Gateway  in first subnet 
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.tf_public_subnet[0].id
  depends_on    = [aws_subnet.tf_public_subnet, aws_eip.nat_gw_eip]

  tags = {
    Name    = "CableBuilder-NGW"
    Project = "var.project_code"
  }
}

resource "aws_route" "nat_gateway-route" {
  route_table_id         = "${aws_route_table.tf_private_rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

# Deploy VPC Security

# Create Bastion Security Group

resource "aws_security_group" "bastion_sg" {
  vpc_id      = aws_vpc.cbg_vpc.id
  name        = "CBG-BastionSG"
  description = "Allow SSH from listed cidr blocks"

  # allow ingress of port 22
  ingress {
    cidr_blocks = var.bastionIngCIDRblock
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
  vpc_id      = aws_vpc.cbg_vpc.id
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
  vpc_id      = aws_vpc.cbg_vpc.id
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
  vpc_id      = aws_vpc.cbg_vpc.id
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
  vpc_id      = aws_vpc.cbg_vpc.id
  subnet_ids = aws_subnet.tf_public_subnet[*].id 
  
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
  
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 400
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
    cidr_block = "0.0.0.0/0"
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
    Name = "CBG_DMZ_Public_NACL"
  }
}

# Create Private Application NACL

resource "aws_network_acl" "app_priv_acl" {
  vpc_id      = aws_vpc.cbg_vpc.id
  subnet_ids = aws_subnet.tf_app_private_subnet[*].id 
  
 # allow ingress port MySQL RDS
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3306
    to_port    = 3306
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
  
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
  # allow egress port MySQL RDS 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3306 
    to_port    = 3306
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
    Name = "CBG_App_Priv_NACL"
  }
}

# Create Private Database NACL

resource "aws_network_acl" "db_priv_acl" {
  vpc_id      = aws_vpc.cbg_vpc.id
  subnet_ids = aws_subnet.tf_db_private_subnet[*].id 
  
 # allow ingress port MySQL RDS
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3306
    to_port    = 3306
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
  
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
  # allow egress port MySQL RDS 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3306 
    to_port    = 3306
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
    Name = "CBG_DB_Priv_NACL"
  }
}
