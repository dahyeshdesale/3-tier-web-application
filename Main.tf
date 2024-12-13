provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "public1" { 
  ami = "ami-053b12d3152c0cc71"
  instance_type = "t2.medium"
  subnet_id = aws_subnet.public1.id 
  tags = { Name = "PublicInstance1" } 
}

# resource "aws_instance" "public2" { 
#   ami = "ami-053b12d3152c0cc71"
#   instance_type = "t2.medium" 
#   subnet_id = aws_subnet.public2.id 
#   tags = { Name = "PublicInstance2" } 
# }

resource "aws_instance" "private1" { 
  ami = "ami-053b12d3152c0cc71"  
  instance_type = "t2.medium" 
  subnet_id = aws_subnet.private1.id 
  tags = { Name = "PrivateInstance1" } 
}

# resource "aws_instance" "private2" { 
#   ami = "ami-053b12d3152c0cc71"  
#   instance_type = "t2.medium" 
#   subnet_id = aws_subnet.private2.id 
#   tags = { Name = "PrivateInstance2" } 
# }

resource "aws_db_subnet_group" "main" {
  name = "main-subnet-group"
  subnet_ids = [aws_subnet.private3.id, aws_subnet.private4.id]
}

resource "aws_db_instance" "main" { 
  allocated_storage = 20 
  engine = "mysql" 
  engine_version = "5.7" 
  instance_class = "db.t2.medium" 
  identifier = "mydb" 
  username = "foo" 
  password = "barbarbar" 
  parameter_group_name = "default.mysql5.7" 
  skip_final_snapshot = true 
  publicly_accessible = false 
  db_subnet_group_name = aws_db_subnet_group.main.name 
  }