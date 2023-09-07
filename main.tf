terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      region = "us-east-1"
    }
  }


resource "aws_vpc" "demotf_vpc" {
cidr_block = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support = true

  tags = {
  Name = "fragile-vpc"
}
}
resource "aws_internet_gateway" "demotf_igw" {
vpc_id = aws_vpc.demotf_vpc.id
}

resource "aws_subnet" "demotf_subnet" {
cidr_block = "10.0.1.0/24"
vpc_id     = aws_vpc.demotf_vpc.id
}
resource "aws_route_table" "demotf_route_table" {
vpc_id = aws_vpc.demotf_vpc.id

route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.demotf_igw.id
}
}
resource "aws_route_table_association" "demotf_route_table_association" {
subnet_id      = aws_subnet.demotf_subnet.id
route_table_id = aws_route_table.demotf_route_table.id
}

resource "aws_security_group" "demotf_security_group" {
name_prefix = "demo_sg_"
vpc_id      = aws_vpc.demotf_vpc.id

ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
}
variable "instance_keypair" {
  description = "AWS EC2 key pair for ssh access"
   type = string
   default ="fragile-kp" #replace with your keypair
  sensitive = true
}
resource "aws_instance" "demo_instance" {
ami           = "ami-0f34c5ae932e6f0e4"
instance_type = "t2.micro"
subnet_id     = aws_subnet.demotf_subnet.id
key_name = var.instance_keypair
vpc_security_group_ids = [aws_security_group.demotf_security_group.id]
associate_public_ip_address = true

tags = {
  Name = "fragile-instance"
}
}

