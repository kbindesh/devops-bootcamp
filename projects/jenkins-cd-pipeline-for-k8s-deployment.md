# Project: Jenkins based Continuous Delivery (CD) pipeline for Kubernetes (Amazon EKS) Apps

## Step-01: Project Oveview

### Step-1.1: Objective

- The primary objective of this project is to establish a fully automated Continuous Delivery (CD) workflow using Jenkins that triggers on code commits, ensuring that only high-quality, scanned, and verified Docker images are deployed to Amazon EKS cluster.

### Step-1.2: Tech stack & Tools

| Tool type                  | Tool/Service Name | Description                                               |
| -------------------------- | ----------------- | --------------------------------------------------------- |
| Source Control             | GitHub            | Centralized code repository                               |
| CI/CD Engine               | Jenkins           | Orchestrates all stages                                   |
| Build Tool                 | Docker            | Package Application into Docker Images                    |
| Image Registry             | Docker Hub        | Centralized place for storing all the Docker Images       |
| Container Orchestrator     | Kubernetes        | Target container platform                                 |
| K8s CLI                    | kubectl           | Kubernetes command line utility                           |
| EKS Cluster Management CLI | eksctl            | Create/Update/Delete AWS EKS Cluster                      |
| AWS CLI                    | aws cli           | Provide authentication services to eksctl and EKS cluster |
| IDE                        | VS Code           | Develop source code and all the configuration files       |

## Step-2: Prerequisites

- AWS Account (with admin privileges)

- GitHub Account (https://github.com/)
- DockerHub Account (https://hub.docker.com/)
- Jenkins Server (https://www.jenkins.io/download/)

## Step-3: Configure your local system for Python App development and EKS cluster creation

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

## Step-4: Develop Python Application

- On your local system, launch VS code (or any other IDE) and clone the following sample python flask application :

```bash
git clone
```

## Step-5: Develop Dockerfile

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

## Step-6: Create a GitHub Repository and push the code

### Step-6.1: Create a new GitHub repo

- Navigate to your GitHub account and create a new GitHub repo with the following specs:
  - Name: py-flask-app
  - Description: A sample python flask app with Jenkins pipeline and k8s manifests
  - Scope: Private

### Step-6.2: Create a GitHub Webhook for Jenkins

- Navigate to your GitHub Account >> Select your repository which has the application source code >> Select **Setting** tab
- Select **Webhooks** >> **Add Webhook**
  - **Payload URL**
    - http://<YOUR_JENKINS_SERVER_PUBLIC_IP_OR_DNS>:8080/github-webhook/
    - Example: http://xx.xx.xx.xx:8080/github-webhook/
  - **Content Type**: application/json
  - **SSL Verification**: Enable SSL Verification
  - **Which events would you like to trigger this webhook?**: Just the push event
  - **Active**: Enable
- Click **Add Webhook** button

## Step-7: Setup an Amazon EKS cluster using `eksctl`

- For EKS Cluster creation, you can use you local system (Linux/MacOS/Win).

- Kindly refer to this lab document for step-by-step process: <br/>https://github.com/kbindesh/eks-bootcamp/blob/master/02-setting-up-eks-cluster.md

- The cluster creation will take at least 20-30mins depending upon the size of cluster.

- Once an Amazon EKS cluster is up and running with at least one worker node, you may continue with the next step.

## Step-8: Configure Jenkins server

### Step-8.1: Install necessary Tools

- git
- docker
- aws cli
- kubectl

### Step-8.2: Install necessary Jenkins Plugins

- AWS Credentials
- Kubernetes Plugin
- Kubernetes CLI Plugin
- Kubernetes Credentials
- Pipeline: Stage view
- Pipeline: AWS Steps - required for withAWS DSL

### Step-8.3: Create Jenkins Credentials

#### Step-8.3.1: Create Credential | Generate and Save `GitHub PAT`

- **Generate GitHub PAT (access token)**
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

#### Step-8.3.2: Create Credential | Generate and save `DockerHub PAT`

- **Generate Docker Hub PAT (access token)**
  - Navigate to https://hub.docker.com/ >> Sign-in
  - Select Account Settings (top-right corner) >> Personal Access Tokens >> Click on **Generate new token** button
    - Description:
    - Expiration Date: None
    - Access Permissions: Read & Write

- Create a Jenkins credentials to save the generated DockerHub PAT:
  - Domain: Global
  - Kind: Username with password
  - Username: `docker-hub-username`
  - Password: `docker-hub-pat`
  - ID: docker_creds
  - Description: DockerHub Credentials

#### Step-8.3.3: Create Credential | Generate and save `AWS Access keys`

- Create an IAM User with the following specs:
  - Name: `eksclusteradmin`
  - AWS Management Console access: Enabled
  - Policy: AdminstratorAccess

- Now, generate access keys for the above created user `eksclusteradmin`. We will need it for setting-up EKS cluster.

- Create a Jenkins credentials to save the generated DockerHub PAT:
  - Domain: global
  - Kind: AWS Credentials
  - Access Key ID: `iam-user-access-key`
  - Secret Access Key: `iam-user-secret-access-key`
  - ID: `aws-credentials`
  - Description: DockerHub Credentials

## Step-9: Develop Jenkinsfile

- Create a new file, _Jenkinsfile_ in the root of the project folder:

```bash
pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-creds')
        AWS_CRED_ID = 'aws-credentials'
        EKS_CLUSTER_NAME = 'labekscluster'
        AWS_REGION = 'us-east-1'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
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
        stage('Push Image to Registry') {
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
        stage('Update Image Tag') {
            steps {
                // Replace placeholder with actual tag
                sh "sed -i 's|__IMAGE_TAG__|${IMAGE_TAG}|g' k8s-specifications/flaskapp-deployment.yml"
            }
        }
        stage('Deploy App to EKS Cluster') {
            steps {
                withAWS(credentials: env.AWS_CRED_ID, region: env.AWS_REGION) {
                    sh 'kubectl get pods -A'
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

## Step-10: Push the Source code and Config files to GitHub

```bash
# Stage all the changes
git add .

# Set remote origin
git remote add origin <your-github-repo-url>

# Push the code
git push -u origin main
```

## Step-11: Create Jenkins Job and Trigger

## Step-12: Access the deployed Application
