terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.0"
    }
  }
}


provider "aws" {
  region = "ap-south-1"
}


resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
      Name = "my-vpc"
    }
}

resource "aws_internet_gateway" "my-gat" {
    vpc_id = aws_vpc.my-vpc.id

    tags = {
      Name = "my-gat"
    }
}

resource "aws_subnet" "my-public" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table" "my-rot" {
    vpc_id = aws_vpc.my-vpc.id

    tags = {
        Name = "my-rot"
    }
}

resource "aws_subnet_route_table_association" "my-assoc" {
  route_table_id = aws_route_table.my-rot.id
  subnet_id = aws_subnet.my-public.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-gat.id
  }
}

resource "aws_security_group" "my-sg" {
  name = "my-sg"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-sg"
  }
}

resource "aws_instance" "my-ec2" {
  ami = "ami-0c55b159cbfafe1f0" #Ubuntu 24.04
  instance_type = "t3.micro"
  subnet_id = aws_subnet.my-public.id
  key_name = "awskey"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my-sg.id]


  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("C:/Users/nb367/OneDrive/Desktop/helloo/awskey.pem")
    host = aws_instance.my-ec2.public_ip
  }

  provisioner "file" {
    source = "./dockerfile"
    destination = "/tmp/dockerfile"
  }

  provisioner "file" {
    source = "./index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install docker.io -y",
      "sudo docker build -t my-apache /tmp/dockerfile",
      "sudo docker run -d -p 5000:80 my-apache"
    ]
  }

  tags = {
    Name = "my-ec2"
  }
}

output "public_ip" {
  value = aws_instance.my-ec2.public_ip
}

output "public_dns" {
  value = aws_instance.my-ec2.public_dns_name
}