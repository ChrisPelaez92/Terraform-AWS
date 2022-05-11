terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-1"
}

#VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
   Name = "Terraform 5000"
 }
}

#public subnet 1a
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.15.0/24"

  tags = {
    Name = "CPF public 1a"
  }
}

#public subnet 1b
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "CPF-public-1b"
  }
}

#public subnet 1c
resource "aws_subnet" "public3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.8.0/24"

  tags = {
    Name = "CPF-public-1c"
  }
}

#privet subnet 1a
resource "aws_subnet" "privet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.12.0/24"

  tags = {
    Name = "CPF-privet-1a"
  }
}

#privet subnet 1b
resource "aws_subnet" "privet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"

  tags = {
    Name = "CPF-privet-1b"
  }
}

#privet subnet 1c
resource "aws_subnet" "Privet3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"

  tags = {
    Name = "CPF-privet-1c"
  }
}

#IG
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "CPF IG"
  }
}

#public router table
resource "aws_route_table" "public-router" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
}
    tags = {
      Name = "Public Route Table CPF"
    }
 }


#Associate route table
  resource "aws_route_table_association" "public-router" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-router.id
}

#Elastic IP
 resource "aws_eip" "eip" {
   depends_on = [aws_internet_gateway.gw]
   vpc      = true
 }


#Nat Gateway
 resource "aws_nat_gateway" "nat" {
 allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT Gateway CPF"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


#Privet router table
resource "aws_route_table" "privet-router" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
}
    tags = {
      Name = "Privet Route Table CPF"
    }
 }



 #Associate Privet route table
   resource "aws_route_table_association" "APR" {
   subnet_id      = aws_subnet.privet1.id
   route_table_id = aws_route_table.privet-router.id
 }
