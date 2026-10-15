# DevOps Pipeline & CI/CD Implementation

## Project Overview

IncidentFlow Lite is a Flask-based incident management application deployed on AWS EC2. This project demonstrates Infrastructure as Code, Docker containerization, automated testing, and cloud deployment.

## Technologies Used

- **AWS:** EC2, VPC, Subnet, Internet Gateway, Route Table, Security Groups
- **Infrastructure as Code:** Terraform
- **Containerization:** Docker
- **CI Automation:** GitHub Actions
- **Application:** Python, Flask, SQLite
- **Testing:** Python unit tests
- **Version Control:** Git and GitHub

## Application Features

- Create and manage technical incidents.
- Track application issues through the dashboard.
- Store incident records using SQLite.
- Check application health through a health endpoint.

## Infrastructure Created with Terraform

The current Terraform configuration provisions:

- Amazon VPC
- Public subnet
- Internet Gateway
- Public route table and subnet association
- Security group for HTTP and restricted SSH access
- Amazon EC2 instance running Amazon Linux 2023

The EC2 instance runs the Flask application in a Docker container. A Docker volume is used to persist the SQLite database across container restarts.

## CI Workflow

GitHub Actions automates application testing and Docker image building when changes are pushed to the repository.

**Note:** Automatic deployment of future commits to EC2 is not yet configured.

## Deployment Workflow

1. Develop the Flask application.
2. Run unit tests through GitHub Actions.
3. Build the Docker image.
4. Provision AWS infrastructure using Terraform.
5. Deploy the containerized application on EC2.
6. Verify application availability using the health endpoint.

## AWS Region

Asia Pacific (Mumbai) — `ap-south-1`

## Future Improvements

- Automate deployment from GitHub Actions to AWS.
- Add container image storage using Amazon ECR.
- Introduce HTTPS and a custom domain.
- Add monitoring and alerting.
- Improve infrastructure security and deployment automation.

## Author

**Name:** Shubham Santosh Karle  
**Roll No.:** 28  
**Class:** TY Cloud Computing

