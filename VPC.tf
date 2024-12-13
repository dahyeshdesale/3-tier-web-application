provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.128.0/20"
  availability_zone       = "us-west-2a"
  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.144.0/20"
  availability_zone       = "us-west-2b"
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.160.0/20"
  availability_zone       = "us-west-2c"
  tags = {
    Name = "private_subnet_3"
  }
}

resource "aws_subnet" "private4" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.176.0/20"
  availability_zone       = "us-west-2d"
  tags = {
    Name = "private_subnet_4"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main_igw"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "main_nat_gw"
  }
}

resource "aws_eip" "main" {
  domain = "vpc"
}

resource "aws_instance" "public_instance1" {
  ami           = "ami-0c55b159cbfafe1f0" # Update with a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "public_instance_1"
  }
}

resource "aws_instance" "public_instance2" {
  ami           = "ami-0c55b159cbfafe1f0" # Update with a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  tags = {
    Name = "public_instance_2"
  }
}

resource "aws_instance" "private_instance1" {
  ami           = "ami-0c55b159cbfafe1f0" # Update with a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private1.id
  tags = {
    Name = "private_instance_1"
  }
}

resource "aws_instance" "private_instance2" {
  ami           = "ami-0c55b159cbfafe1f0" # Update with a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private2.id
  tags = {
    Name = "private_instance_2"
  }
}

resource "aws_elb" "public_elb" {
  name = "public-load-balancer"
  listeners {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  subnets         = [aws_subnet.public1.id, aws_subnet.public2.id]
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "public_elb"
  }
}

resource "aws_elb" "private_elb" {
  name = "private-load-balancer"
  listeners {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  subnets         = [aws_subnet.private1.id, aws_subnet.private2.id]
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "private_elb"
  }
}

resource "aws_autoscaling_group" "public_asg" {
  availability_zones   = ["us-west-2a", "us-west-2b"]
  desired_capacity     = 2
  max_size             = 2
  min_size             = 1
  health_check_grace_period = 300
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.public_lc.id
  load_balancers       = [aws_elb.public_elb.id]

}

resource "aws_autoscaling_group" "private_asg" {
  availability_zones   = ["us-west-2a", "us-west-2b"]
  desired_capacity     = 2
  max_size             = 2
  min_size             = 1
  health_check_grace_period = 300
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.private_lc.id
  load_balancers       = [aws_elb.private_elb.id]

}

resource "aws_launch_configuration" "public_lc" {
  name          = "public_launch_configuration"
  image_id      = "ami-0c55b159cbfafe1f0" # Update with a valid AMI ID
  instance_type = "t2.micro"
  security_groups = [aws_security_group.public_sg.id]
}

resource "aws_launch_configuration" "private_lc" {
  name          = "private_launch_configuration"
  image_id      = "ami-0c55b159cbfafe1f0" # Update with a valid AMI ID
  instance_type = "t2.micro"
  security_groups = [aws_security_group.private_sg.id]
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  identifier           = "mydb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id, aws_subnet.private4.id]
  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public_sg"
  }
}  
