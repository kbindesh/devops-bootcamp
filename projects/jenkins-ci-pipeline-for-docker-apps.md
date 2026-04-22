# Project-XX: Jenkins CI pipeline for Docker | Build, Push, and Deploy Application

## Project Overview

- In this project, you will create a Jenkins based continuous integration pipeline for:
  - Packaging an app into Docker Image
  - Pushing the docker image to registry
  - Deploying dockerized app to Docker host

## Prerequisites

- Jenkins Server
- GitHub Account
- Docker Account

## Develop an Application (source code)

## Create a Dockerfile

## Create a Jenkinsfile

```bash
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'kbindesh/my-python-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Prepare Workspace') {
            steps {
                // Remove the jenkins-project directory if it exists
                sh 'rm -rf jenkins-project'
            }
        }

        stage('Approval Required') {
            steps {
                script {
                    def userInput = input(id: 'userInput', message: 'Approve and Provide docker image', parameters: [
                        string(name: 'DOCKER_IMAGE', defaultValue: 'defaultValue', description: 'Enter the docker image')
                    ])
                    env.DOCKER_IMAGE = userInput
                }
            }
        }
        stage('Checkout Code') {
            steps {
                sh 'git clone https://github.com/kbindesh/jenkins-python-project.git'
            }
        }

        stage('Set Up Environment') {
            steps {
                // Install libraries and packages required for build and tests
                sh 'pip install -r jenkins-project/requirements.txt'
            }
        }

        stage('Unit Testing') {
            steps {
                // Use pytest for unit testing
                sh 'pytest'
            }
        }

        stage('Login to DockerHub') {
            steps {
                // Use DockerHub credentials to login
                withCredentials([string(credentialsId: 'dockerhubpwd', variable: 'dockerhubpwd')]) {
                    sh "docker login -u max -p ${dockerhubpwd} localhost:5000"
                    echo 'Login successfully'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${IMAGE_TAG}"
                    sh "docker build -t ${IMAGE_TAG} ."
                }
            }
        }

        stage('Deploy Docker Image') {
            steps {
                script {
                    echo "Deploying Docker image ${env.DOCKER_IMAGE}"
                    sh "docker run -d ${env.DOCKER_IMAGE}"
                }
            }
        }
    }
}
```

## Create a GitHub repository with a Webhook for our Application

## Push the Application code + Jenkinsfile + Dockerfile to GitHub

## Generate DockerHub Security Token (PAT)

- Sign in to your DockerHub Account
- Click on user drop-down menu (top-right corner) >> Account Settings
- Select **Personal Account Token** from the left-side panel >> Click **Generate new token** button.
  - Description: Token for Jenkins
  - Expiration Date: None
  - Access Permission: Read & Write

- Copy the generated token and store it at safe place. We'll need it in the next step.

## Save the DockerHub Access Token (PAT) on Jenkins server

- In order to allow Jenkins server to be able to connect to DockerHub Account and push the docker image, we must create credentials and save the dockerhub credentials over there.

- Now create a new Jenkins credential with the following specifications:
  - **docker-creds**
    - Purpose: To store docker hub credentials
    - Kind: Username and Password
    - Scope: Global
    - ID: `docker-creds`
    - Description: Docker Hub credentials
    - Username: `your-dockerhub-acc-username`
    - Password: `your-dockerhub-acc-token`

## Key Cencepts Covered in this Project

- GitHub Webhook triggering Jenkins Pipelines
- Developing Dockerfile
- Developing Jenkinfile
- Packaging Application in Docker Images
- Managing Jenkins Credentials
- Creating customized Jenkins Pipelines
- Consuming environment variables in Jenkins Pipeline
- Configuring Parameterized Builds in Jenkins

## Create a Jenkins Pipeline (Job)

- Enable `This project is parameterized` checkbox.
  - Add a string parameter named `DOCKER_IMAGE` for Docker image to be deployed.
  - You will have to provide the value for this parameter when you will run this Jenkins job.
