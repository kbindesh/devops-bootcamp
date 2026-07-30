# Project: Load-Balanced Multi-AZ AWS Infrastructure with Remote backend

## :zap: Step-01: Project Overview

- This project automates the deployment of a secure networking and compute infrastructure.
- It sets up a custom VPC partitioned into public and private subnets across multiple Availability Zones.
- Public subnets house an Internet Gateway and a NAT Gateway, allowing instances in private subnets to securely access the internet for updates without being exposed directly.

- The compute tier consists of EC2 instances provisioned inside the private subnets for enhanced security.
- Each instance is attached to an external EBS volume for persistent data storage.
- Traffic from the public internet is received by a public-facing Application Load Balancer (ELB), which securely routes and distributes the load to the private EC2 instances.

## :zap: 02. Solution Architecture

![terraform-project-diag](images\terraform-project-diag.png)

## :file_folder: 03. Terraform Project Directory Structure

```
terraform-aws-infra/
├── backend.tf
├── providers.tf
├── variables.tf
├── main.tf
└── outputs.tf
```

## :low_brightness: 04. Prerequisites

1. Terraform

2. Visual Studio Code (or any other IDE)
3. AWS Account with the following
   - Custom IAM User with _AdministratorAccess_ policy &rarr; Generate Access keys
4. AWS CLI

### 4.1 Authenticate Terraform to AWS

- Run the `aws configure` command via your terminal. This securely saves your keys to `~/.aws/credentials`.

```bash
aws configure

# You will be prompted to enter the following parameters:
#   AWS Access Key ID: Your IAM user access key.
#   AWS Secret Access Key: Your IAM user secret key.
#   Default region name: The primary region you deploy into (e.g., us-east-1).
#   Default output format: json.
```

## :low_brightness: 05. Develop Terraform Script

### 5.1 backend.tf

Configures the remote S3 bucket for storing state.

#### 5.1.1 (Prerequisite) Create S3 Bucket for Terraform Remote backend

- Create a new S3 bucket with following specs:
  - Name: _Suitable bucket name_
  - Type: General Purpose
  - Region: us-east-1

#### 5.1.2 `backend.tf` Source code

```bash
terraform {
  backend "s3" {
    bucket         = "your-bucket-name"
    key            = "env/prod/sample-web-app.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}
```

### 5.2 `providers.tf`

Configures the required provider constraints.

```bash
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

### 5.3 `variables.tf`

Input configuration variables for environment-wide reusability.

```bash
variable "aws_region" {
  type        = string
  description = "Target AWS region for deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment identifier tag"
  default     = "production"
}

variable "vpc_cidr" {
  type        = string
  description = "Base CIDR block for the custom VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the private subnets"
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance hardware sizing"
  default     = "t3.micro"
}
```

### 5.3 `main.tf`

The core engine utilizing meta-arguments (count, depends_on, lifecycle, each) to iteratively create high-availability components.

```bash
# Fetch available AZs dynamically in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# 1. Networking Infrastructure (VPC & Gateways)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.environment}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-igw" }
}

# 2. Subnets (Iterating over AZs using Meta-Argument 'count')
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${var.environment}-public-sn-${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "${var.environment}-private-sn-${count.index + 1}" }
}

# 3. NAT Gateway for Secure Private Subnet Outbound Traffic
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.environment}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Placed in first public subnet

  tags       = { Name = "${var.environment}-nat-gw" }
  depends_on = [aws_internet_gateway.igw] # Explicit meta-argument dependency
}

# 4. Routing Tables and Associations
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.environment}-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.environment}-private-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# 5. Security Groups
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Allow inbound public traffic to web layer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_nodes" {
  name        = "${var.environment}-ec2-sg"
  description = "Restrict traffic to entry via ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Tied directly to ALB SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6. EC2 Instances Layer (using 'count')
resource "aws_instance" "web" {
  count                  = length(aws_subnet.private)
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.web_nodes.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Host Node ${count.index + 1}</h1>" > /var/www/html/index.html
              EOF

  tags = { Name = "${var.environment}-web-node-${count.index + 1}" }
}

# 7. Persistent EBS Storage and Attachments
resource "aws_ebs_volume" "data" {
  count             = length(aws_subnet.private)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  size              = 20
  type              = "gp3"

  tags = { Name = "${var.environment}-data-vol-${count.index + 1}" }
}

resource "aws_volume_attachment" "ebs_att" {
  count        = length(aws_subnet.private)
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.data[count.index].id
  instance_id  = aws_instance.web[count.index].id
  force_detach = true
}

# 8. Elastic Load Balancer Infrastructure (ALB)
resource "aws_lb" "external_alb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id # Splat expression meta-argument

  tags = { Environment = var.environment }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web_attach" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}
```

### 5.4 `outputs.tf`

Outputs operational properties for engineers to consume upon deployment execution.

```output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the custom VPC"
}

output "load_balancer_dns" {
  value       = aws_lb.external_alb.domain_name
  description = "Public URL of the application load balancer to access your web tier"
}

output "private_instance_ips" {
  value       = aws_instance.web[*].private_ip
  description = "List of internal private IP addresses assigned to web tier nodes"
}
```

## 06. Deploy the AWS Infrastucture

```
terraform init

terraform validate

terraform plan

terraform apply --auto-approve
```

## :rocket: 07. Production Best Practices Followed

- **Secure Networking**
  - Web servers are isolated in private subnets.
- **State Management**
  - State files are stored remotely in an S3 Backend and to prevent concurrent execution conflicts.
- **Modularity & Security**
  - Least-privilege security groups are configured, separating load balancer entry points from backend application ports.
