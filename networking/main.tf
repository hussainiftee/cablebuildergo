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
    Name = "CBG_PublicRT"
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
    Name    = "CBG_PUBLIC_${count.index + 1}"
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
    Name = "CBG_PrivateRT"
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