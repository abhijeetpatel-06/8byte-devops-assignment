# 8Byte DevOps Assignment

## Overview

This project demonstrates an end-to-end DevOps workflow covering infrastructure provisioning, deployment automation, monitoring, logging, and documentation.

The goal of this assignment is to showcase how a production-ready application can be deployed and managed on AWS using modern DevOps practices.

---

# Project Structure

```text
8byte-devops-assignment/
│
├── app/
│   ├── app.js
│   ├── Dockerfile
│   ├── package.json
│   └── test/
│
├── terraform/
│   ├── provider.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── rds.tf
│   ├── alb.tf
│   ├── security_groups.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf
│
├── monitoring/
│   ├── prometheus/
│   ├── loki/
│   ├── promtail/
│   └── docker-compose.yml
│
└── .github/
    └── workflows/
        └── cicd.yml
```

---

# Part 1: Infrastructure Provisioning

Infrastructure is provisioned using Terraform on AWS.

## Components Created

### VPC

A dedicated Virtual Private Cloud is created to isolate application resources.

### Public Subnet

Used for:

- Application Server (EC2)
- Load Balancer

### Private Subnet

Used for:

- PostgreSQL RDS Database

Keeping the database private improves security by preventing direct internet access.

### EC2 Instance

The application is hosted on an Amazon EC2 instance.

Responsibilities:

- Run Docker containers
- Host application services
- Serve application traffic

### Application Load Balancer (ALB)

The Load Balancer distributes incoming traffic to the application instance.

Benefits:

- High Availability
- Better Scalability
- Easier future expansion

### PostgreSQL RDS

AWS RDS is used for managed PostgreSQL database hosting.

Benefits:

- Automated backups
- Managed maintenance
- Improved reliability

### Security Groups

Security groups are configured with minimum required access.

Example:

- HTTP (80)
- HTTPS (443)
- SSH (22)
- Database access restricted internally

---

# Terraform State Management

Remote state storage is configured using AWS S3.

Benefits:

- Centralized state file
- Better team collaboration
- Prevents accidental state loss

---

# Terraform Variables

Reusable variables are defined in:

```text
terraform/variables.tf
```

Examples:

- AWS Region
- Instance Type
- Database Configuration
- Network CIDR Blocks

This keeps the infrastructure flexible and easy to modify.

---

# Terraform Outputs

Useful outputs are exposed after deployment:

- ALB DNS Name
- EC2 Public IP
- RDS Endpoint

Example:

```bash
terraform output
```

---

# Part 2: Deployment Automation

GitHub Actions is used for CI/CD automation.

Workflow file:

```text
.github/workflows/cicd.yml
```

## CI/CD Flow

```text
Developer Push
        │
        ▼
 GitHub Actions
        │
        ▼
 Run Tests
        │
        ▼
 Security Scan
        │
        ▼
 Docker Build
        │
        ▼
 Push Image
        │
        ▼
 Deploy to Staging
        │
        ▼
 Manual Approval
        │
        ▼
 Deploy to Production
```

---

## CI Features

### Automated Testing

Tests run automatically when:

- Pull Request is created
- Code is pushed

### Docker Image Build

Application is containerized using Docker.

Benefits:

- Consistent deployments
- Environment independence

### Security Scanning

Dependency and container vulnerability scanning can be integrated before deployment.

Example tools:

- Trivy
- npm audit

### Deployment

After successful validation:

- Image is pushed to registry
- Application is deployed to staging
- Production deployment requires approval

---

# Part 3: Monitoring and Logging

Monitoring stack is located in:

```text
monitoring/
```

Components used:

### Prometheus

Collects and stores metrics from infrastructure and applications.

Monitored metrics include:

- CPU Usage
- Memory Usage
- Disk Usage
- Network Usage

### Loki

Centralized log aggregation system.

Collects:

- Application Logs
- System Logs
- Access Logs

### Promtail

Responsible for collecting logs and forwarding them to Loki.

### Grafana

Used for visualization and dashboard creation.

---

# Dashboards

## Infrastructure Dashboard

Tracks:

- CPU Utilization
- Memory Usage
- Disk Usage
- Network Activity

Purpose:

Identify infrastructure bottlenecks and resource issues.

---

## Application Dashboard

Tracks:

- Request Rate
- Error Rate
- Response Time
- Service Availability

Purpose:

Monitor application health and user experience.

---

# Logging Strategy

Centralized logging helps in:

- Faster troubleshooting
- Root Cause Analysis
- Incident investigation

Log sources:

- Application Logs
- System Logs
- Access Logs

---

# Security Considerations

Several security best practices are followed:

### Network Isolation

Database is deployed in a private subnet.

### Security Groups

Only required ports are exposed.

### Secret Management

Sensitive values such as passwords should never be hardcoded.

Recommended approaches:

- GitHub Secrets
- AWS Secrets Manager

### Least Privilege Principle

Resources should only receive permissions required for their functionality.

---

# Backup Strategy

RDS automated backups can be enabled to protect database data.

Benefits:

- Disaster recovery
- Point-in-time restoration
- Reduced data loss risk

---

# Cost Optimization

Several decisions were made to keep costs under control:

- Small EC2 instance sizes
- Single environment deployment
- Managed database service
- Reusable Terraform modules
- Automated infrastructure provisioning

These choices help reduce unnecessary cloud expenses.

---

# Architecture Decisions

### Why Terraform?

Terraform provides:

- Infrastructure as Code
- Reproducibility
- Version Control
- Automation

### Why Docker?

Docker ensures:

- Consistent runtime environments
- Simplified deployment process

### Why GitHub Actions?

GitHub Actions offers:

- Native GitHub integration
- Automated workflows
- Easy CI/CD management

### Why Prometheus & Grafana?

Industry-standard tools for:

- Monitoring
- Alerting
- Visualization

---

# Challenges Faced

### Challenge 1

Terraform state bucket conflicts.

Resolution:

Used unique bucket naming and backend configuration.

### Challenge 2

Terraform state locking issues.

Resolution:

Verified state backend configuration and lock handling.

### Challenge 3

Git repository and submodule issues.

Resolution:

Removed incorrect repository references and restructured folders.

### Challenge 4

Infrastructure provisioning delays.

Resolution:

Validated AWS resource dependencies and Terraform execution order.

---

# Future Improvements

Possible improvements for production environments:

- ECS/EKS deployment
- Auto Scaling Groups
- Multi-AZ RDS
- WAF Integration
- CloudWatch Alerts
- Automated Rollbacks
- Blue/Green Deployments

---

# How to Deploy

## Infrastructure

```bash
cd terraform

terraform init

terraform plan

terraform apply
```

## Application

```bash
cd app

docker build -t todo-app .

docker run -p 3000:3000 todo-app
```

## Monitoring

```bash
cd monitoring

docker-compose up -d
```

---

# Author

**Abhijeet Patel**

DevOps Engineer Intern | AWS | Linux | Docker | Terraform | Monitoring | CI/CD