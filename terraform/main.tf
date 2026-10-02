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
  region = "ap-south-1"
}

# -------------------------
# VPC
# -------------------------

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

# -------------------------
# Public Subnet
# -------------------------

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

# -------------------------
# Private Subnet
# -------------------------

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name      = "DevOps-Private-Subnet"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name      = "DevOps-Internet-Gateway"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

# -------------------------
# Route Table
# -------------------------

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

# -------------------------
# Route Table Association
# -------------------------

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# -------------------------
# Security Group
# -------------------------

resource "aws_security_group" "devops_security_group" {
  name        = "devops-cicd-security-group"
  description = "Security group for DevOps CI/CD project"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name      = "DevOps-CICD-Security-Group"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

# -------------------------
# S3 Bucket
# -------------------------

resource "aws_s3_bucket" "terraform_bucket" {
  bucket_prefix = "devops-cicd-terraform-"

  tags = {
    Name      = "DevOps-CICD-Terraform-Bucket"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}

# -------------------------
# ECR Repository
# -------------------------

resource "aws_ecr_repository" "application_repository" {
  name                 = "devops-cicd-application"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "DevOps-CICD-ECR"
    Project   = "DevOps-Pipeline-CICD"
    ManagedBy = "Terraform"
  }
}