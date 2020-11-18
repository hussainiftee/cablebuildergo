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
    Name = "CodeBuilderGoVPC"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "cbg_vpc_igw" {
  vpc_id = aws_vpc.cbg_vpc.id

  tags = {
    Name = "CodeBuilderGoIGW"
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
    Name = "dmz_public_${count.index + 1}"
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
    Name = "app_private_${count.index + 1}"
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
    Name = "db_private_${count.index + 1}"
  }
}

resource "aws_route_table_association" "tf_db_private_assoc" {
  count          = length(aws_subnet.tf_db_private_subnet)
  subnet_id      = aws_subnet.tf_db_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.tf_private_rt.id
}

#  NAT Gateway

resource "aws_eip" "nat_gw_eip" {
  vpc = true
  
   tags = {
    Name = "CodeBuilder-NGW-EIP"
  }
}

resource "aws_nat_gateway" "gw" {
  count=1
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id      = element(aws_subnet.tf_public_subnet.*.id, count.index)
  depends_on    = [aws_subnet.tf_public_subnet]
  
   tags = {
    Name = "CodeBuilder-NGW"
  }
  
}

resource "aws_route_table_association" "a_route_for_a_subnet" {
  count=1
  subnet_id      = element(aws_subnet.tf_public_subnet.*.id, count.index)
  route_table_id = "${aws_route_table.tf_private_rt.id}"
}

resource "aws_route" "nat_gateway-route" {
  count=1
  route_table_id = "${aws_route_table.tf_private_rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
}