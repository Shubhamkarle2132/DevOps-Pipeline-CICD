
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "devops-project"
}

# Find the latest Amazon Linux 2023 x86_64 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# VPC
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "DevOps-CICD-VPC"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "DevOps-Public-Subnet"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

# Internet gateway
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name      = "DevOps-Internet-Gateway"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name      = "DevOps-Public-Route-Table"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security group: HTTP public, SSH restricted to your current IP
resource "aws_security_group" "devops_security_group" {
  name        = "devops-cicd-security-group"
  description = "Security group for IncidentFlow Lite"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "HTTP website"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from my current public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["152.56.2.88/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "DevOps-CICD-Security-Group"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

# EC2 instance: Docker + IncidentFlow Lite
resource "aws_instance" "incidentflow" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.devops_security_group.id]
  associate_public_ip_address = true
  key_name                    = "incidentflow-ec2-key"

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    exec > >(tee -a /var/log/incidentflow-setup.log) 2>&1

    dnf install -y docker git
    systemctl enable --now docker

    git clone https://github.com/Shubhamkarle2132/DevOps-Pipeline-CICD.git /opt/incidentflow
    cd /opt/incidentflow

    docker build -t incidentflow-lite:1.0 .

    docker volume create incidentflow-data

    docker run -d \
      --name incidentflow-app \
      --restart unless-stopped \
      -p 80:5000 \
      -v incidentflow-data:/data \
      incidentflow-lite:1.0
  EOF

  tags = {
    Name      = "IncidentFlow-Lite-EC2"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }

  depends_on = [
    aws_route_table_association.public_subnet_association
  ]
}

output "website_url" {
  description = "IncidentFlow Lite website URL"
  value       = "http://${aws_instance.incidentflow.public_ip}"
}

output "instance_public_ip" {
  description = "EC2 public IPv4 address"
  value       = aws_instance.incidentflow.public_ip
}
