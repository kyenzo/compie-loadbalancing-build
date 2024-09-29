# compie-loadbalancing-build# README

## Simple Website Architecture with Terraform

### Table of Contents

- [Introduction](#introduction)
- [Architecture Overview](#architecture-overview)
- [Components](#components)
  - [Virtual Private Cloud (VPC)](#virtual-private-cloud-vpc)
  - [Subnets](#subnets)
  - [Internet Gateway and Route Tables](#internet-gateway-and-route-tables)
  - [Security Groups](#security-groups)
  - [EC2 Instances and Auto Scaling Group](#ec2-instances-and-auto-scaling-group)
  - [Application Load Balancer (ALB)](#application-load-balancer-alb)
  - [DynamoDB](#dynamodb)
  - [CloudFront Distribution](#cloudfront-distribution)
  - [On-Premises Server Connectivity (Optional)](#on-premises-server-connectivity-optional)
  - [Monitoring and Notifications](#monitoring-and-notifications)
  - [AWS Secrets Manager](#aws-secrets-manager)
  - [AWS CodeDeploy](#aws-codedeploy)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [Cleanup](#cleanup)
- [Additional Notes](#additional-notes)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Introduction

This project uses **Terraform** to deploy a scalable, secure, and efficient web application infrastructure on **AWS**. It includes:

- **EC2 Instances**: Managed by an Auto Scaling Group with a Launch Template.
- **Load Balancer**: An Application Load Balancer (ALB) to distribute incoming traffic.
- **DynamoDB**: A NoSQL database for storing data.
- **CloudFront**: A Content Delivery Network (CDN) for global content distribution.
- **On-Premises Server Connectivity**: Optional secure access from an on-premises server to DynamoDB.
- **Monitoring & Notifications**: CloudWatch Alarms and SNS for sending SMS notifications.
- **AWS Secrets Manager**: Securely stores secrets with read-only access granted to another AWS account.
- **AWS CodeDeploy**: Automates code deployment to EC2 instances.

---

## Architecture Overview

The infrastructure consists of:

- A **VPC** with public and private subnets across two availability zones.
- **EC2 Instances** in an Auto Scaling Group behind an **Application Load Balancer**.
- A **DynamoDB** table for data storage.
- A **CloudFront** distribution in front of the ALB for content caching.
- Optional connectivity for an **on-premises server** to access DynamoDB.
- **CloudWatch Alarms** and **SNS Topics** for monitoring and notifications.
- **Secrets Manager** for managing secrets securely.
- **CodeDeploy** for continuous deployment of application code.


---

## Components

### Virtual Private Cloud (VPC)

- **Resource**: `aws_vpc.main`
- **CIDR Block**: `10.0.0.0/16`
- **Purpose**: Provides an isolated network environment for the resources.

### Subnets

- **Public Subnet** (`aws_subnet.public`)
  - CIDR Block: `10.0.1.0/24`
  - Availability Zone: `us-east-1a`
  - Public IPs Enabled.
- **Private Subnet** (`aws_subnet.private`)
  - CIDR Block: `10.0.2.0/24`
  - Availability Zone: `us-east-1b`

### Internet Gateway and Route Tables

- **Internet Gateway** (`aws_internet_gateway.gw`)
  - Connects the VPC to the internet.
- **Route Table** (`aws_route_table.public`)
  - Routes internet traffic from the public subnet through the Internet Gateway.

### Security Groups

- **Web Security Group** (`aws_security_group.web_sg`)
  - Allows inbound HTTP (port 80) and SSH (port 22) traffic.
  - Applied to EC2 instances and the ALB.
- **On-Premises Security Group** (`aws_security_group.on_prem_sg`)
  - **Optional**: Allows the on-premises server to access DynamoDB.

### EC2 Instances and Auto Scaling Group

- **AMI**: Latest Amazon Linux 2 (`data.aws_ami.amazon_linux`)
- **Launch Template** (`aws_launch_template.web`)
  - Configures EC2 instances with user data to install and run a web server.
- **Auto Scaling Group** (`aws_autoscaling_group.web_asg`)
  - Manages EC2 instances, ensuring a minimum and maximum number of instances.
  - Attached to the ALB Target Group for load balancing.
  - Health checks configured with the ALB.

### Application Load Balancer (ALB)

- **Load Balancer** (`aws_lb.web_lb`)
  - Distributes incoming HTTP traffic across EC2 instances.
- **Target Group** (`aws_lb_target_group.web_tg`)
  - Registers EC2 instances from the Auto Scaling Group.
- **Listener** (`aws_lb_listener.web_listener`)
  - Listens on port 80 and forwards traffic to the Target Group.

### DynamoDB

- **Table** (`aws_dynamodb_table.web_db`)
  - Table Name: `web-table`
  - Billing Mode: `PAY_PER_REQUEST`
  - Primary Key: `id` (String)

### CloudFront Distribution

- **Distribution** (`aws_cloudfront_distribution.web_cdn`)
  - Caches content from the ALB globally.
  - Default root object: `index.html`
  - Viewer protocol policy: Redirects HTTP to HTTPS.

### On-Premises Server Connectivity (Optional)

- **Security Group** (`aws_security_group.on_prem_sg`)
  - Allows the on-premises server to securely connect to DynamoDB.
- **Variables**
  - `enable_on_prem_connection`: Toggle to enable/disable this feature.
  - `on_prem_ip`: IP address of the on-premises server.

### Monitoring and Notifications

- **SNS Topic** (`aws_sns_topic.scale_topic`)
  - Used to send notifications.
- **SNS Subscription** (`aws_sns_topic_subscription.sms_subscription`)
  - Sends SMS messages to administrators.
- **CloudWatch Alarm** (`aws_cloudwatch_metric_alarm.cpu_alarm`)
  - Monitors CPU utilization of EC2 instances.
  - Triggers notifications when CPU usage exceeds a threshold.

### AWS Secrets Manager

- **Secret** (`aws_secretsmanager_secret.db_secret`)
  - Stores sensitive data like database credentials.
- **Secret Version** (`aws_secretsmanager_secret_version.db_secret_version`)
  - Contains the actual secret string.
- **Secret Policy** (`aws_secretsmanager_secret_policy.db_secret_policy`)
  - Grants read-only access to a specified AWS account.

### AWS CodeDeploy

- **IAM Role** (`aws_iam_role.codedeploy_role`)
  - Allows CodeDeploy to interact with AWS services.
- **CodeDeploy Application** (`aws_codedeploy_app.web_app`)
  - Represents the application to be deployed.
- **Deployment Group** (`aws_codedeploy_deployment_group.web_deployment_group`)
  - Defines settings for deployments, including the Auto Scaling Group and Load Balancer.

---

## Prerequisites

- **AWS Account**: Ensure you have an AWS account with appropriate permissions.
- **Terraform**: Install Terraform (v0.12+ recommended).
- **AWS CLI**: Configure the AWS CLI with your credentials.
- **Key Pair**: Create an EC2 key pair in AWS and update `key_name` in `main.tf`.
- **Replace Placeholders**: Update placeholders in the code with your actual values:
  - `your-key-pair`
  - `+1234567890` (Admin phone number)
  - `123456789012` (AWS Account ID for Secrets Manager access)
  - `on_prem_ip` (IP address of your on-premises server, if applicable)

---

## Deploying the Infrastructure

To deploy the infrastructure using Terraform, execute the following commands in your terminal:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```
