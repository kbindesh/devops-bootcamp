# Push Docker Image in ECR

- To push a Docker image to Amazon Elastic Container Registry (ECR) from an EC2 instance, follow these sequential steps:

## 01. Prerequisites & Permissions

### 1.1 Create an IAM Role

- Ensure your EC2 instance has the necessary permissions to interact with ECR.

- Create an **IAM Role** with the `AmazonEC2ContainerRegistryFullAccess` managed policy and attach it to your EC2 instance.
  - **Name**: dockerHostRoleForECRAccess
  - **Policy**: AmazonEC2ContainerRegistryFullAccess
- Associate the above created IAM Role i.e. _dockerHostRoleForECRAccess_ to your Docker Host machine (EC2 instance).

### 1.2 AWS CLI

### 1.3 Docker

```bash
# Install Docker (Amazon Linux 2023)
sudo dnf update -y
sudo dnf install docker -y
sudo systemctl start docker
sudo usermod -a -G docker ec2-user  # Log out and back in for this to take effect

# To verify docker installation, check the version
docker version
```

### 1.4 Sample Application 

- You may clone sample Python Flask Application code along with Dockerfile from here: 

```bash
git clone https://github.com/kbindesh/sample-python-flask-app.git
```

## 02. Create an AWS ECR Repository

- You must have a repository in ECR to hold your image:

```bash
aws ecr create-repository --repository-name <your-repo-name> --region <your-region>

# Example
aws ecr create-repository --repository-name flaskapp --region us-east-1
```

## 02. Authenticate Docker to AWS ECR

- Retrieve an authentication token and authenticate your Docker client to the registry

```bash
# Syntax
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com

# Example
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 154511248558.dkr.ecr.us-east-1.amazonaws.com
```

## 03. Build and Tag the Image

- Build your local Docker image or use an existing one, then tag it with the ECR repository URI:

```bash
# Build the image - Syntax
docker build -t <local-image-name> .

# Adding a tag to the above created image - Syntax
docker tag <local-image-name>:latest <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/<your-repo-name>:latest


# Example
docker build -t flaskapp .

docker tag flaskapp:latest 154511248558.dkr.ecr.us-east-1.amazonaws.com/flaskapp:latest
```

## 04. Push the Image to AWS ECR

```bash
# Syntax
docker push <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/<your-repo-name>:latest

# Example
docker push 154511248558.dkr.ecr.us-east-1.amazonaws.com/flaskapp:latest
```
