provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}

# Subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public_subnets_cidr, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.private_subnets_cidr, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "main-nat-gw"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

# EC2 Instances
resource "aws_instance" "public_instance" {
  count = 2
  ami           = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  availability_zone = "ap-south-1a"

  tags = {
    Name = "public-instance-${count.index + 1}"
  }
}

resource "aws_instance" "private_instance" {
  count = 2
  ami           = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"
  subnet_id     = element(aws_subnet.private_subnet[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.private_sg.name]
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-instance-${count.index + 1}"
  }
}

# Application Load Balancers
resource "aws_lb" "public_lb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]

  tags = {
    Name = "public-lb"
  }
}

resource "aws_lb" "private_lb" {
  name               = "private-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_sg.id]
  subnets            = [aws_subnet.private_subnet[1].id, aws_subnet.private_subnet[1].id]

  tags = {
    Name = "private-lb"
  }
}

# Auto Scaling Groups
resource "aws_launch_template" "public_lc" {
  name          = "public-lc"
  image_id      = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "public_asg" {
  launch_template {
    id = aws_launch_template.public_lc.id
    version = "$Latest"
  } 
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = aws_subnet.public_subnet[*].id

  tag {
    key                 = "Name"
    value               = "public-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "private_lc" {
  name          = "private-lc"
  image_id      = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "private_asg" {
  launch_template {
    id = aws_launch_template.private_lc.id
    version = "$Latest"
  } 
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = aws_subnet.private_subnet[*].id

  tag {
    key                 = "Name"
    value               = "private-asg"
    propagate_at_launch = true
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami           = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "bastion-host"
  }
}

# RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet[2].id, aws_subnet.private_subnet[3].id]

  tags = {
    Name = "main-db-subnet-group"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot  = true

  tags = {
    Name = "mydb"
  }
}
