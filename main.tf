terraform {
  required_version = "0.12.18"
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
  cidr_block = var.cidr_block

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

resource "aws_subnet" "public" {
  for_each = var.availability_zones

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.key)
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = {
    Name               = "nsoroka-training-pub-sn-${each.value}"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_subnet" "private_front" {
  for_each = var.availability_zones

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 10 + each.key)
  availability_zone = each.value

  tags = {
    Name               = "nsoroka-training-prfr-sn-${each.value}"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_subnet" "private_back" {
  for_each = var.availability_zones

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 20 + each.key)
  availability_zone = each.value

  tags = {
    Name               = "nsoroka-training-prbk-sn-${each.value}"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_subnet" "private_db" {
  for_each = var.availability_zones

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 30 + each.key)
  availability_zone = each.value

  tags = {
    Name               = "nsoroka-training-prdb-sn-${each.value}"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

module "main_rt" {
  source = "./modules/route_table"

  name                    = "nsoroka-training-main-rt"
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.igw.id
  associations_subnet_ids = [aws_subnet.public.*.id]

  tags = {
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

module "nat_rt" {
  source = "./modules/route_table"

  name                    = "nsoroka-training-nat-rt"
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "0.0.0.0/0"
  instance_id             = aws_instance.nat.id
  associations_subnet_ids = [aws_subnet.private_front.*.id, aws_subnet.private_back.*.id]

  tags = {
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
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
  public_key = file("/home/linux/.ssh/nsoroka-key.pub")
}

resource "aws_instance" "bastion" {
  ami                    = "ami-04b9e92b5572fa0d1"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id              = aws_subnet.public[0].id
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
  subnet_id              = aws_subnet.public[0].id
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
  for_each = var.availability_zones

  ami                    = "ami-04b9e92b5572fa0d1"
  instance_type          = "t2.micro"
  availability_zone      = each.value
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.https.id]
  subnet_id              = aws_subnet.private_front[each.key].id

  tags = {
    Name               = "nsoroka-training-front-${each.value}"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

resource "aws_instance" "back" {
  for_each = var.availability_zones

  ami                    = "ami-04b9e92b5572fa0d1"
  instance_type          = "t2.micro"
  availability_zone      = each.value
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.https.id]
  subnet_id              = aws_subnet.private_back[each.key].id

  tags = {
    Name               = "nsoroka-training-back-${each.value}"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

# public lb
module "public_lb" {
  source = "./modules/public_lb"

  vpc_id              = aws_vpc.main.id
  name                = "nsoroka-training-lb"
  target_ids          = [aws_instance.front.id]
  security_groups_ids = [aws_security_group.https.id]
  subnet_ids          = [aws_subnet.public.*.id]
  certificate_domain  = "*.test.coherentprojects.net"

  tags = {
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}

# back lb
module "back_lb" {
  source = "./modules/network_lb"

  vpc_id      = aws_vpc.main.id
  target_port = 8080
  internal    = true
  name        = "nsoroka-training-back-lb"
  target_ids  = [aws_instance.back.id]
  subnet_ids  = [aws_subnet.private_back.*.id]

  tags = {
    env                = var.environment
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
  subnet_ids = [aws_subnet.private_db.*.id]

  tags = {
    Name               = "nsoroka-training-db-sg"
    "coherent:owner"   = "nikolaisoroka@coherentsolutions.com"
    "coherent:project" = "devops-training"
  }
}






