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

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.my-gat.id
    }

    tags = {
        Name = "my-rot"
    }
}

resource "aws_route_table_association" "my-assoc" {
  route_table_id = aws_route_table.my-rot.id
  subnet_id = aws_subnet.my-public.id

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
  ami = "ami-03f4878755434977f" #Ubuntu 24.04
  instance_type = "t3.micro"
  subnet_id = aws_subnet.my-public.id
  key_name = "awskey"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my-sg.id]


  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("/var/lib/jenkins/awskey.pem")
    host = aws_instance.my-ec2.public_ip
  }

  provisioner "file" {
    source = "./dockerfile"
    destination = "/home/ubuntu/dockerfile"
  }

  provisioner "file" {
    source = "./index.html"
    destination = "/home/ubuntu/index.html"
  }

  provisioner "file" {
    source = "deployment.yml"
    destination = "/home/ubuntu/deployment.yml"
  }

  resource "aws_instance" "my-ec2" {

  ami           = "ami-03f4878755434977f"
  instance_type = "t2.medium"
  key_name      = "awskey"

  vpc_security_group_ids = [aws_security_group.my-sg.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/awskey.pem")
    host        = self.public_ip
  }

  # Copy Dockerfile
  provisioner "file" {
    source      = "./Dockerfile"
    destination = "/home/ubuntu/Dockerfile"
  }

  # Copy HTML
  provisioner "file" {
    source      = "./index.html"
    destination = "/home/ubuntu/index.html"
  }

  # Copy Kubernetes Deployment
  provisioner "file" {
    source      = "./deployment.yml"
    destination = "/home/ubuntu/deployment.yml"
  }

  # Copy Kubernetes Service
  provisioner "file" {
    source      = "./service.yml"
    destination = "/home/ubuntu/service.yml"
  }

  provisioner "remote-exec" {

    inline = [

      # Update packages
      "sudo apt update -y",

      # Install Docker
      "sudo apt install docker.io -y",

      # Start Docker
      "sudo systemctl start docker",
      "sudo systemctl enable docker",

      # Add ubuntu user to docker group
      "sudo usermod -aG docker ubuntu",

      # Install kubectl
      "sudo snap install kubectl --classic",

      # Install Minikube
      "curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",

      "chmod +x minikube-linux-amd64",

      "sudo mv minikube-linux-amd64 /usr/local/bin/minikube",

      # Start Minikube
      "minikube start --driver=docker",

      # Create app directory
      "mkdir -p /home/ubuntu/app",

      # Copy files
      "cp /home/ubuntu/Dockerfile /home/ubuntu/app/",
      "cp /home/ubuntu/index.html /home/ubuntu/app/",
      "cp /home/ubuntu/deployment.yml /home/ubuntu/app/",
      "cp /home/ubuntu/service.yml /home/ubuntu/app/",

      # Build Docker image
      "cd /home/ubuntu/app && sudo docker build -t my-apache .",

      # Load image into Minikube
      "minikube image load my-apache",

      # Deploy to Kubernetes
      "kubectl apply -f /home/ubuntu/app/deployment.yml",


      # Verify
      "kubectl get pods",
      "kubectl get svc",
      "kubectl get nodes"
    ]
  }



  tags = {
    Name = "my-ec2"
  }
}

output "public_ip" {
  value = aws_instance.my-ec2.public_ip
}
