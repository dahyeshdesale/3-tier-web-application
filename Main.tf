provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "app" {
  name          = "app-launch-configuration"
  image_id      = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"
  
  security_groups = [aws_security_group.app_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "web" {
  ami           = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "WebInstance"
  }
}

resource "aws_instance" "db" {
  ami           = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private1.id
  security_groups = [aws_security_group.db_sg.id]

  tags = {
    Name = "DBInstance"
  }
}

