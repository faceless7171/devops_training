terraform {
  required_version = "0.12.17"
}

provider "aws" {
  version = "~> 2.40"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::242906888793:role/AWS_Sandbox"
    session_name = "AWS_Sandbox"
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "nsoroka-training-vpc"
    "coherent:owner" = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "nsoroka-training-igw"
    "coherent:owner" = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_subnet" "all" {
  for_each = var.subnets

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.value.name
    "coherent:owner" = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

#Route tables
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "nsoroka-training-rt"
    "coherent:owner" = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_route_table_association" "main_a" {
  subnet_id      = aws_subnet.all["public_a"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "main_b" {
  subnet_id      = aws_subnet.all["public_b"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "nsoroka-training-rt-nat"
    "coherent:owner" = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_route_table_association" "nat_a" {
  subnet_id      = aws_subnet.all["private_a"].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table_association" "nat_b" {
  subnet_id      = aws_subnet.all["private_b"].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table_association" "nat_c" {
  subnet_id      = aws_subnet.all["private_db_a"].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table_association" "nat_d" {
  subnet_id      = aws_subnet.all["private_db_b"].id
  route_table_id = aws_route_table.nat.id
}

# Security groups
resource "aws_security_group" "ssh" {
  name        = "nsoroka-training-sg-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["104.59.125.84/32", "216.70.7.11/32", "80.94.174.82/32", "82.209.242.80/29", "86.57.155.180/32", "86.57.158.250/32", "146.120.13.128/28"]
  }

  tags = {
    Name = "nsoroka-training-sg-ssh"
    "coherent:owner" = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_security_group" "https" {
  name        = "nsoroka-training-sg-http-https"
  description = "Allow http, https inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "nsoroka-training-sg-http-https"
    "coherent:owner" = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

# EC2 amis
resource "aws_ami" "example" {
  name                = "nsoroka-training-bastion"
  virtualization_type = "hvm"
  root_device_name    = "/dev/sda1"

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = "snap-xxxxxxxx"
    volume_size = 8
  }
}

resource "null_resource" "sdf" {
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.private_ip} >> private_ips.txt"
  }
}

