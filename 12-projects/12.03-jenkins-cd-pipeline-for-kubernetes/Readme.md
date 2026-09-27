# Project: Jenkins base Continuous Delivery (CD) Pipeline for building and deploying Apps on Amazon Elastic Kubernetes Service (EKS) Cluster

## Project Overview

- This project automates the deployment of Python Flask App.
- It is a fully automated Continuous Integration and Continuous Delivery (CI/CD) pipeline to build, containerize, and deploy a Python Flask web application onto an Amazon Elastic Kubernetes Service (EKS) cluster.
- Leveraging Jenkins as the primary automation engine, the pipeline ensures that every code change pushed to GitHub undergoes automated testing, code quality checks, and containerization before being seamlessly rolled out to production (Amazon EKS cluster) with zero downtime.

## Tech Stacks/Tools used in the Project

| Tool/Service Name  | Purpose                                                   |
| ------------------ | --------------------------------------------------------- |
| Visual Studio Code | IDE                                                       |
| Git                | Version Control System                                    |
| GitHub             | Centralized Version Control                               |
| Amazon EC2         | Compute service for Jenkins Server                        |
| Jenkins            | Automation Server to implement CI/CD Pipelines            |
| SonarQube          | Static Code Analysis                                      |
| Docker             | Container Runtime                                         |
| Docker Hub         | Artifact Management                                       |
| Kubernetes (EKS)   | Container Orchestrator (managed)                          |
| KUBECTL            | CLI for Kubernetes                                        |
| EKSCTL             | CLI for setting-up & mananging EKS cluster infrastructure |
| AWS CLI            | CLI for manage & automate AWS infrastructure              |
| Python             | Application Programming Language                          |
| pip                | Python Package Manager                                    |
| Python Flask       | Python Web Development Framework                          |
| Pytest             | Python testing frameworks                                 |
| Gunicorn           | WSGI HTTP server wrapper used inside the container        |

## Architecture & Pipeline Workflow

```bash
[Developer] ➔ Push to [GitHub] ➔ (Webhook) ➔ [Jenkins Server]
                                                    │
    ┌───────────────────────────────────────────────┴──────────────────────────────┐
    ▼                               ▼                                              ▼
[1. Checkout & Test] ➔ [2. Build & Push Docker Image] ➔ [3. Kubernetes Deployment (EKS)]
```

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
  - It includes an extended visualization of Pipeline build history on the index page of a flow project, under _Stage View_.
- **Docker Pipeline**
  - It allows building, testing, and using Docker images from Jenkins Pipeline projects.
- **AnsiColor**

- **AWS Credentials Plugin**
  - Allows you to securely store _AWS Access Keys_ and _Secret Keys_ inside the Jenkins Credentials store.

### Install Tools

Rather than relying heavily on heavy Jenkins plugins, the industry best practice is to keep Jenkins "dumb" and ensure your Jenkins Agent/Runner has the following binaries pre-installed:

1. Docker Engine
2. kubectl
3. AWS CLI

- Log into your Jenkins server (here Amazon Linux 2023 EC2) via SSH and install the following tools:

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

```bash
# Download the latest version of official "kubectl" binary or swap out the $(...) section with a specific version tag like v1.28.0
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# (optional) Download the v1.32.0 version of official "kubectl" binary

# Make the binary executable
sudo chmod +x ./kubectl

# Move the binary into your executable path
sudo mv ./kubectl /usr/local/bin/kubectl

# Verify the installation
kubectl version --client --output=yaml
```

#### Install `AWS CLI`

## Create and configure AWS IAM Users for Amazon EKS cluster creations & App Deployment using Jenkins

You need two distinct AWS identities (ideally IAM roles, or IAM users):

- `ekscluster-admin`
  - Administrator identity to create the cluster with _eksctl_

- `jenkins-eks-deployer`
  - Automation identity for _Jenkins_ to deploy applications

### Create IAM User-1 | Cluster Creator | Generate credentials for creating and managing EKS Cluster creation

The user or role running eksctl create cluster needs high-level privileges because eksctl provisions VPCs, CloudFormation stacks, IAM roles, and the EKS control plane.

- **Name**: `ekscluster-admin`
- **Credentials**: Programmatic Access (AWS Access Key ID and Secret Access Key)

#### Required AWS Permission

- _AdministratorAccess_ (Recommended for initial setup because eksctl creates complex underlying resources).

- Core Services Used by _eksctl_
  - Amazon EKS (eks:\*)
  - Amazon EC2 / VPC (ec2:\*)
  - AWS CloudFormation (cloudformation:\*)
  - AWS IAM (iam:\*)
  - Amazon CloudWatch Logs (logs:\*)

### Create IAM User-2 | Jenkins Deployment User | Generate credentials for Jenkins to Deploy Apps on EKS Cluster creation

The Jenkins user or role needs permissions to authenticate with the EKS cluster, run kubectl commands, and optionally pull/push container images.

- **Name**: `jenkins-eks-deployer`
- **Credentials**: Programmatic Access (AWS Access Key ID and Secret Access Key)

#### Required AWS Permissions

Attach the following inline or managed IAM policy to jenkins-deployer. This gives Jenkins permission to view the EKS cluster details and pull images from your private registry:

- eks:DescribeCluster (To allow kubectl to connect to the EKS cluster)
- ecr:GetAuthorizationToken
- ecr:BatchCheckLayerAvailability
- ecr:GetDownloadUrlForLayer (If Jenkins pulls container images from Amazon ECR)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKSAccess",
      "Effect": "Allow",
      "Action": ["eks:DescribeCluster"],
      "Resource": "arn:aws:eks:YOUR_REGION:YOUR_ACCOUNT_ID:cluster/YOUR_CLUSTER_NAME"
    },
    {
      "Sid": "ECRAccess",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
```

#### Required Kubernetes RBAC Permissions (via _aws-auth_ ConfigMap)

- The Jenkins IAM user/role must be mapped inside the cluster's aws-auth ConfigMap.

- It needs a Kubernetes Role or ClusterRole granting permissions like _get, list, create, update, and patch_ on deployments, services, and pods within your target namespace

### Save _jenkins-eks-deployer_ Access keys on Jenkins

## Generate DockerHub Access token (PAT) and Save it on Jenkins

- Type: Username and Password
- ID: `dockerhub-creds`

## Setup Amazon Elastic Kubernetes Service (EKS) Cluster using AWS CLI & eksctl

### Install kubectl, eksctl and AWS CLI

### Create Amazon EKS cluster and Node group

```bash

# Login to AWS as "ekscluster-admin" user with the access keys
aws configure

# Create EKS Cluster without worker nodes
eksctl create cluster --name=labekscluster --region=us-east-1 --zones=us-east-1a,us-east-1b --without-nodegroup

# Get List of clusters
eksctl get cluster

# Create a new EC2 Key Pair | Will be used in next step for worker nodes

# Create Node Group (replace cluster name and keypair with your resource names)
eksctl create nodegroup --cluster=labekscluster --region=us-east-1 --name=binWinWebServerKey --node-type=t3.small --nodes=1 --nodes-min=1 --nodes-max=4 --node-volume-size=20 --ssh-access --ssh-public-key=eks-nodes-keypair --managed --asg-access --external-dns-access --full-ecr-access --appmesh-access --alb-ingress-access

# List EKS clusters
eksctl get cluster

# List NodeGroups in a cluster
eksctl get nodegroup --cluster=<clusterName>

# List Nodes in current kubernetes cluster
kubectl get nodes -o wide

# Your kubectl context should be automatically changed to new cluster
kubectl config view --minify
```

## Configure Jenkins identity (jenkins-eks-deployer) to Deploy Apps on EKS and Map it inside EKS

- Because AWS EKS manages cluster access via Kubernetes RBAC, _AWS permissions alone will not let Jenkins deploy apps_.

- The cluster creator (ekscluster-admin) must explicitly map `jenkins-eks-deployer` inside Amazon EKS Cluster.

### Create an IAM User (jenkins-eks-deployer)

First, create the IAM user that Jenkins will use to authenticate with AWS.

1. Open the AWS Management Console and navigate to the IAM Console.
2. In the left navigation pane, click **Users** &rarr; **Create user**.
   - Enter a username (e.g., jenkins-eks-deployer)
   - On the Set permissions page, select _Attach policies directly_.- Click **Next**, review the user details, and click **Create user**.

### Attach the Minimum Required IAM Policy

Instead of granting broad administrator access, create a restricted policy that allows Jenkins to describe the EKS cluster.

1. IAM Console &rarr; Policies &rarr; Create policy.

2. Switch to the JSON tab and paste the following policy (replace your-region, your-account-id, and your-cluster-name with your actual values):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["eks:DescribeCluster", "eks:ListClusters"],
      "Resource": "arn:aws:eks:your-region:your-account-id:cluster/your-cluster-name"
    }
  ]
}
```

3. Click Next &rarr;
   - Name the policy: `JenkinsEKSMinimalPolicy`

4. Return to your `jenkins-eks-deployer` user &rarr; Permissions tab &rarr; Add permissions, and attach this new policy i.e. _JenkinsEKSMinimalPolicy_ to the user.

### Generate IAM User Access Keys for Jenkins

Jenkins requires credentials to authenticate API calls.

1. In the user summary page for `jenkins-eks-deployer`, click the Security credentials tab.
2. Scroll down to Access keys and click Create access key.
3. Select Application running outside AWS (or Command Line Interface) as the use case.
4. Download the .csv file containing the Access Key ID and Secret Access Key.

### Map the IAM User to EKS Kubernetes RBAC

```bash
aws eks create-access-entry \
    --cluster-name your-cluster-name \
    --principal-arn arn:aws:iam::your-account-id:user/jenkins-eks-deployer \
    --type STANDARD

aws eks associate-access-policy \
    --cluster-name your-cluster-name \
    --principal-arn arn:aws:iam::your-account-id:user/jenkins-eks-deployer \
    --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
    --access-scope type=cluster
```

### Save IAM User Credentials (jenkins-eks-deployer) on the Jenkins server

Now, save the `jenkins-eks-deployer` access keys inside Jenkins so your build pipeline can access them securely.

1. Open your Jenkins Dashboard and go to Manage Jenkins > Credentials > System > Global credentials.
2. Click **Add Credentials**
   - **Kind**: AWS Credentials (requires the Pipeline: AWS Steps plugin)
   - **ID**: jenkins-aws-eks-secret
   - **Description**: Credentials for EKS application deployment
   - **Access Key ID**: (Paste your access key)
   - **Secret Access Key**: (Paste your secret key)
3. Click **Create**

## Develop Application source code along with all the neccessary files

### Develop Application source code

### Develop Dockerfile

### Develop Jenkinsfile

### Develop Kubernetes Manifests

## Push all the changes to the GitHub

### Create a new GitHub Repository

### Create a GitHub webhook for Jenkins

### Push the changes to GitHub Repo

## Create Jenkins Pipeline

## Verify the Application Deployment on Amazon EKS
