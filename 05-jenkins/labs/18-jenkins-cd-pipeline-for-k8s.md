# Hands-on Lab: Jenkins base CD Pipeline for AWS EKS Application deployment

## Prerequisites

- Jenkins Server with the following tools configured:
  - Git
  - Java
- GitHub Repo with a Python project
- DockerHub Account
- SonarQube Account

## Configure Jenkins Server

### Install Plugins

- **Pipeline: Stage View**

- **Docker Pipeline**
- **Pipeline: AWS Steps**
  - Provides the `withAWS` block in your Jenkinsfile.
- **AWS Credentials Plugin**
  - Allows you to securely store _AWS Access Keys_ and _Secret Keys_ inside the Jenkins Credentials store.

### Install Tools

Rather than relying heavily on heavy Jenkins plugins, the industry best practice is to keep Jenkins "dumb" and ensure your Jenkins Agent/Runner has the following binaries pre-installed:

- Docker Engine
- kubectl
- AWS CLI

#### Install `Docker Engine`

```bash
# Update the package management tool database
sudo dnf update -y

# Install the Docker engine package
sudo dnf install -y docker

# Start the Docker daemon
sudo systemctl start docker

# Enable Docker to automatically boot up on system restarts
sudo systemctl enable docker
```

- Add the jenkins user to the docker group so that Jenkins can execute docker build and docker push commands without requiring sudo privileges.

```bash
# Add the jenkins user account to the docker group
sudo usermod -aG docker jenkins

# Force a restart of the Jenkins service to apply the group membership changes
sudo systemctl restart jenkins
```

- Once Jenkins restarts, you can run this command to verify that the jenkins user can interact with the Docker daemon successfully:

```bash
sudo su - jenkins -s /bin/bash -c "docker info"

# If you see system configuration outputs instead of a "permission denied" error, your access setup is complete
```

#### Install `kubectl`

#### Install `AWS CLI`

## Create and configure AWS IAM User credentials for EKS App deployment using Jenkins

### Create an IAM User

### Generate Access Keys

### Save the Access Keys on Jenkins

## Generate DockerHub Access token (PAT) and Save it on Jenkins

- Type: Username and Password
- ID: `dockerhub-creds`

## Setup AWS Elastic Kubernetes Service (EKS) Cluster using AWS CLI & eksctl

## Develop Application source code along with all the neccessary files

### Develop Application source code

### Develop Dockerfile

### Develop Jenkinsfile

### Develop Kubernetes Manifests

## Push all the changes to the GitHub

### Create a new GitHub Repository

### Push the changes to GitHub Repo

### Create a GitHub webhook for Jenkins
