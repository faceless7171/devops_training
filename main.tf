terraform {
  required_version = "0.12.17"
}

provider "aws" {
  version = "~> 2.40"
  region  = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::242906888793:role/AWS_Sandbox"
    session_name = "AWS_Sandbox"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name               = "nsoroka-training-vpc"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name               = "nsoroka-training-igw"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_subnet" "all" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name               = each.value.name
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
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
    Name               = "nsoroka-training-rt"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
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

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }

  tags = {
    Name               = "nsoroka-training-rt-nat"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
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

resource "aws_route_table_association" "nat_e" {
  subnet_id      = aws_subnet.all["private_back_a"].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table_association" "nat_f" {
  subnet_id      = aws_subnet.all["private_back_b"].id
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name               = "nsoroka-training-sg-ssh"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name               = "nsoroka-training-sg-http-https"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

# EC2
resource "aws_key_pair" "main" {
  key_name   = "nsoroka-key"
  public_key = file("/home/nikolaisoroka/.ssh/nsoroka-key.pub")
}

resource "aws_instance" "bastion" {
  ami                    = "ami-04b9e92b5572fa0d1"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id              = aws_subnet.all["public_a"].id
  user_data              = <<EOF
#!/bin/bash
    eval "$(ssh-agent -s)"
  EOF

  tags = {
    Name               = "nsoroka-training-bastion"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_instance" "nat" {
  ami                    = "ami-04b9e92b5572fa0d1"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.https.id]
  subnet_id              = aws_subnet.all["public_a"].id
  source_dest_check      = false
  user_data              = <<EOF
#!/bin/bash
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo iptables -t nat -A POSTROUTING -o eth0 -s 10.0.0.0/16 -j MASQUERADE
  EOF

  tags = {
    Name               = "nsoroka-training-nat"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_instance" "front" {
  ami                    = "ami-04b9e92b5572fa0d1"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.https.id]
  subnet_id              = aws_subnet.all["private_a"].id

  tags = {
    Name               = "nsoroka-training-front"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_instance" "back" {
  ami                    = "ami-04b9e92b5572fa0d1"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.https.id]
  subnet_id              = aws_subnet.all["private_back_a"].id

  tags = {
    Name               = "nsoroka-training-back"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

# public lb
module "public_lb" {
  source = "./modules/public_lb"

  vpc_id = aws_vpc.main.id
  name = "nsoroka-training-lb"
  target_ids = [aws_instance.front.id]
  security_groups_ids = [aws_security_group.https.id]
  subnet_ids = [aws_subnet.all["public_a"].id, aws_subnet.all["public_b"].id]
  certificate_domain = "*.test.coherentprojects.net"

  tags = {
    env = var.environment
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

# back lb
module "back_lb" {
  source = "./modules/network_lb"

  vpc_id = aws_vpc.main.id
  target_port = 8080
  internal = true
  name = "nsoroka-training-back-lb"
  target_ids = [aws_instance.back.id]
  subnet_ids = [aws_subnet.all["private_back_a"].id, aws_subnet.all["private_back_b"].id]

  tags = {
    env = var.environment
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "nsoroka-training-rds"
  availability_zone      = "us-east-1a"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "mydb"
  username               = "admin"
  password               = "admin12345"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  maintenance_window     = "Mon:00:00-Mon:03:00"
  port                   = "3306"
  vpc_security_group_ids = [aws_security_group.https.id]

  tags = {
    Name               = "nsoroka-training-rds"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "nsoroka-training-db-sg"
  subnet_ids = [aws_subnet.all["private_db_a"].id, aws_subnet.all["private_db_b"].id]

  tags = {
    Name               = "nsoroka-training-db-sg"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}






