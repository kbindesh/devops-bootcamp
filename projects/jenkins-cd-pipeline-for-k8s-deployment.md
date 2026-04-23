# Project: Jenkins based Continuous Delivery (CD) pipeline for Kubernetes (Amazon EKS) Apps

## Project Oveview

- This project

## Prerequisites

- AWS Account (with admin privileges)

- GitHub Account
- DockerHub Account
- Jenkins Server

## Configure your local system for Python App development and EKS cluster creation

- VS Code (https://code.visualstudio.com/download)
  - _Plugins_
    1. Kubernetes
    2. Git
    3. YAML
    4. Prettier

- Git (https://git-scm.com/install/)
- Python + pip (https://www.python.org/downloads/) | 3.11 or above
- AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- kubectl (https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
- eksctl (https://docs.aws.amazon.com/eks/latest/eksctl/installation.html)

## Develop Python Application

- On your local system, launch VS code (or any other IDE) and clone the following sample python flask application :

```bash
git clone
```

## Develop Dockerfile

- Create a new file, _Dockerfile_ in the root of the project folder:

```bash
FROM python:3.11-alpine
LABEL author="kbindesh" description="sample python flask app"
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 8080
ENTRYPOINT ["python"]
CMD ["src/app.py"]
```

## Create a GitHub Repository and push the code

### Create a new GitHub repo

- Navigate to your GitHub account and create a new GitHub repo with the following specs:
  - Name: py-flask-app
  - Description: A sample python flask app with Jenkins pipeline and k8s manifests
  - Scope: Private

### Create a GitHub Webhook for Jenkins

## Setup an Amazon EKS cluster

### Create an IAM User and generate access keys

### Create an EKS Cluster using `eksctl`

## Configure Jenkins server

### Install necessary Tools

- git
- docker
- aws cli
- kubectl

### Install necessary Jenkins Plugins

- AWS Credentials
- Kubernetes Plugin
- Kubernetes CLI Plugin
- Kubernetes Credentials
- Pipeline: Stage view
- Pipeline: AWS Steps - required for withAWS DSL

### Create Jenkins Credentials

#### Create Credential | Generate and Save `GitHub PAT`

- **Generate GitHub PAT**
  - Navigate to your GitHub Account >> Settings >> Developer Settings >> Personal access tokens >> Tokens (classic)
    - Click on **Generate new token** button >> Generate new token(classic).
    - **Note**: Token for jenkins
    - **Expiration**: No expiration
    - **Select scope**: Check `repo` checkbox (Full control of private repositories)
    - Click on **Generate Token** button.

- **Create a Jenkins credentials to save the generated `GitHub PAT`**:
  - Domain: global
  - Kind: Username and Password
  - Username: `your-github-username`
  - Password: `your-github-pat`
  - ID: github-creds
  - Description: GitHub Credentials

#### Create Credential | Generate and save `DockerHub PAT`

- Generate Docker Hub PAT

- Create a Jenkins credentials to save the generated DockerHub PAT:
  - Domain: Global
  - Kind: Username with password
  - Username: `docker-hub-username`
  - Password: `docker-hub-pat`
  - ID: docker_creds
  - Description: DockerHub Credentials

#### Create Credential | Generate and save `AWS Access keys`

- Create an IAM User with the following specs:
  - Name: `eksclusteradmin`
  - AWS Management Console access: Enabled
  - Policy: AdminstratorAccess

- Now, generate access keys for the above created user `eksclusteradmin`. We will need it for setting-up EKS cluster.

- Create a Jenkins credentials to save the generated DockerHub PAT:
  - Domain: global
  - Kind: AWS Credentials
  - Access Key ID:
  - Secret Access Key:
  - ID: `aws-credentials`
  - Description: DockerHub Credentials

## Develop Jenkinsfile

- Create a new file, _Jenkinsfile_ in the root of the project folder:

```bash
pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_creds')
        EKS_CLUSTER_NAME = 'labekscluster'
        AWS_REGION = 'us-east-1'
        AWS_CRED_ID = 'aws-credentials'
        PATH = "$PATH:/opt"
    }
    stages {

        stage('Building an Image') {
            steps {
                sh 'docker build -t kbindesh/flaskapp:$BUILD_NUMBER .'
            }
        }
        stage('Connecting to DockerHub') {
            steps{
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                echo "Successfully connected to DockerHub Account"
            }
        }
        stage('Push Docker Image') {
            steps{
                sh 'docker push kbindesh/flaskapp:$BUILD_NUMBER'
                echo "Pushed the kbindesh/flaskapp:${BUILD_NUMBER} image successfully"
            }
        }
        stage('Configure EKS kubeconfig') {
            steps {
                // Use the AWS CLI to authenticate and update kubeconfig
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.AWS_CRED_ID]]) {
                    sh "aws configure set region ${AWS_REGION}"
                    sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"
                    echo "Configured kubeconfig for EKS cluster: ${EKS_CLUSTER_NAME}"
                }
            }
        }
        stage('Deploy App to EKS') {
            steps {
                withAWS(credentials: env.AWS_CRED_ID, region: env.AWS_REGION) {
                    sh 'kubectl config view'
                    sh 'aws sts get-caller-identity'
                    sh 'kubectl --kubeconfig=/var/lib/jenkins/.kube/config get pods -A'
                    sh 'kubectl apply -f k8s-specifications/flaskapp-deployment.yml'
                    echo "Python Flask app deployed successfully"
                }
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}
```

## Push the Source code and Config files to GitHub

```bash
# Stage all the changes
git add .

# Set remote origin
git remote add origin <your-github-repo-url>

# Push the code
git push -u origin main
```

## Create Jenkins Job and Trigger

## Access the deployed Application
