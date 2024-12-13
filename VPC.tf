# provider "aws" {
#   region = "ap-south-1"
# }
# #VPC
# resource "aws_vpc" "3-tier-vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     name = "3tair-main-vpc"
#   }
# }

# # 2Public & 4Private subnets
# resource "aws_subnet" "Public-Subnet-1" {
#   vpc_id = aws_vpc.3-tier-vpc.id
#   cidr_block = "10.0.0.0/20"
#   availability_zone = "ap-south-1a"
# }

# resource "aws_subnet" "Public-Subnet-2" {
#   vpc_id = aws_vpc.3-tier-vpc.id
#   cidr_block = "10.0.16.0/20"
#   availability_zone = "ap-south-1b"
# }

# resource "aws_subnet" "Private-Subnet-1" {
#   vpc_id = aws_vpc.3-tier-vpc.id 
#   cidr_block = "10.0.128.0/20"
#   availability_zone = "ap-south-1a"
# }

# resource "aws_subnet" "Private-Subnet-2" {
#   vpc_id = aws_vpc.3-tier-vpc.id
#   cidr_block = "10.0.144.0/20"
#   availability_zone = "ap-south-1b"
# }

# resource "aws_subnet" "Private-Subnet-3" {
#   vpc_id = aws_vpc.3-tier-vpc.id
#   cidr_block = "10.0.160.0/20"
#   availability_zone = "ap-south-1a"
# }

# resource "aws_subnet" "Private-Subnet-4" {
#   vpc_id = aws_vpc.3-tier-vpc.id
#   cidr_block = "10.0.176.0/20"
#   availability_zone = "ap-south-1b"
# }

# #Internet Gateway
# resource "aws_internet_gateway" "3-tier-igw" {
#   vpc_id = aws_vpc.3-tier-vpc.id
# }

# #Public Routable
# resource "aws_route_table" "3tier-Public" {
#   vpc_id = aws_vpc.3-tier-vpc.id
#   route = {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.3-tier-igw.id
#   }
# }

# resource "aws_route_table_association" "Public-Subnet1" {
#   subnet_id = aws_subnet.Public-Subnet-1.id
#   route_table_id = aws_route_table.3tier-Public.id
# }

# resource "aws_route_table_association" "Public-Subnet2" {
#   subnet_id = aws_subnet.Public-Subnet-2.id
#   route_table_id = aws_route_table.3tier-Public.id
# }
