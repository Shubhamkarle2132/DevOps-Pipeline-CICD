# DevOps Pipeline & CI/CD Implementation

## Project Description

This project implements an automated CI/CD pipeline with Infrastructure as Code (IaC) using Terraform on Amazon Web Services (AWS).

## Step 3 – Infrastructure as Code Setup

Terraform is used to provision the AWS infrastructure required for the DevOps project.

## AWS Resources Created

- Amazon VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- Route Table
- Security Group
- Amazon S3 Bucket
- Amazon ECR Repository

## Terraform Workflow

The infrastructure was created using the following Terraform workflow:

1. terraform init
2. terraform validate
3. terraform plan
4. terraform apply

## AWS Region

Asia Pacific (Mumbai) - ap-south-1

## Project Architecture

Terraform provisions the AWS networking, storage, and container infrastructure required for the DevOps CI/CD project.

## Future CI/CD Implementation

The next stage will include:

- GitHub integration
- AWS CodePipeline
- AWS CodeBuild
- Docker
- Amazon ECR
- Amazon ECS/Fargate
- Application Load Balancer
- CloudWatch monitoring

## Author

**Name:** Shubham Karle  
**Roll No:** 28  
**Class:** TY Cloud Computing