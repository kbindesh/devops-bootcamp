# Project-XX: Jenkins based CI/CD pipeline for building and deploying Python App on a VM

## Project Overview

- In this project, we will create a Jenkins based continuous delivery pipeline for building and deploying a Python Flask Application on a Virtual Machine (EC2 Instance).

## Prerequisites

- Jenkins Server
- GitHub Account

## Develop an Application (Python Flask)

## Create a GitHub repository for Python Flask App with a Webhook

## Push the Application code to GitHub

## Setting-up Target Server (prod/test) for running Python App

### Create a VM for Python Application (target env)

- Create a new EC2 Instance with the following specifications:
  - Name: prod-app-server
  - Instance Type: t2.micro
  - Key pair: create a new or select an existing keypair
  - Network and Subnet: leave to defaults
  - Security group
    - Ingress: Allow SSH, HTTPS, HTTP, 5000
    - Egress: Default (allow all)
  - Storage: 10GB GP2

### Configure the Application Server for running Python App

- Connect to the App Server VM over SSH.

- Now, we will create a new directory in the /home/ec2-user/`app`

```bash
# Create a new directory for the python app
mkdir app

cd app

pwd
[You would be inside /home/ec2-user/app directory]
```

- **Install Python** - https://www.python.org/downloads/

```bash

# Before installing Python, check if you already have Python installed on the VM
python3 --version

# In case python is not present, you may download and install it from the above provided link
```

- Create Python virtual environment for our Application `/home/ec2-user/app/venv`

```bash
# Create a virtual env for our app
python3 -m venv venv

# List all the files from /home/ec2-user/app directory
ls

[The preceding command output will list only one directory i.e venv]
```

### Create systemd service file for Python App - `/etc/systemd/system/flaskapp.service`

- Create a new file `flaskapp.service`:

```
cd /etc/systemd/system
sudo vi flaskapp.service
```

- Add the following contents to the `flaskapp.service` file

```
[Unit]
Description=flask app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/app/
Environment="PATH=/home/ec2-user/app/venv/bin"
ExecStart=/home/ec2-user/app/venv/bin/python3 /home/ec2-user/app/app.py
```

- Reload the daemon and start the `flaskapp` service:

```bash
sudo systemctl daemon-reload

sudo systemctl enable flaskapp.service

sudo systemctl start flaskapp.service

sudo systemctl status flaskapp

[Even after starting flaskapp service explicitly, the service status will be "failed"]

[As Python application file app.py is not yet deployed on the server]
```

## Configuring Jenkins Pipeline

- The Jenkins pipeline should have the following tasks in order:
  1. Checkout the code from GitHub
  2. Install dependencies
  3. Test Code using PyTest
  4. Package Application code
  5. Deploy Application to the Target server (here, prod-serer)
  6. Install the Dependencies on the server
  7. Restart the flaskapp service

### Create Jenkins Credentials for storing target server details

- In order to allow Jenkins server to be able to connect to our target server (prod-server) and deploy application, we must create credentials and save the information over there.

- We will create two Jenkins `credentials`, as follows:
  1. **ssh-key**
     - To store ssh private key of the target server
     - Kind: SSH Username with private key
     - Scope: Global
     - ID: `ssh-key`
     - Description: Production server ssh private key
     - Username: ec2-user
     - Private key: `paste-the-contents-of-private-key`
  2. **prod-server-ip**
     - To store the IP address of the target server.
     - Kind: Secret Text
     - Scope: Global
     - Secret: `your-prod-server-ip-address`
     - ID: `prod-server-ip`
     - Description: IP Address of the Production server

## Create a Jenkins Pipeline

- Jenkins Dashboard >> New Item
  - Item Name: flaskapp-prod-deployment-pipeline
  - Type: Pipeline
  - Build Trigger: GitHub hook trigger for GitSCM polling

  - Pipeline
    - Definition: Pipeline script from SCM
      - SCM: Git
        - Repository URL: `your-github-repo-url`
        - Credentials: `your-github-repo-creds`
        - Branches to Build: \*/main
    - Script Path: Jenkinsfile

## Create a new Jenkinfile

```bash
pipeline {
  agent any

  environment {
    SERVER_IP = credentials('prod-server-ip')
  }

  stages{
    stage('Install Dependencies'){
      steps {
        sh "pip install -r requirments.txt"
      }
    }
    stage('Performing unit testing'){
      steps {
        sh "pytest"
      }
    }
    stage('Packaging the App'){
      steps {
        sh "zip -r myapp.zip ./* -x '*.git*'"
        sh "ls -lart"
      }
    }
    stage('Deploying App to Server'){
      steps{
        withCredentials(){}
          sh '''
          scp -i $MY_SSH_KEY -o StrictHostKeyChecking=no myapp.zip ${username}@${SERVER_IP}:/home/ec2-user/
          ssh -i $MY_SSH_KEY -o StrictHostKeyChecking=no ${username}@${SERVER_IP} << EOF
            unzip -o /home/ec2-user/myapp.zip -d /home/ec2-user/app/
            source app/venv/bin/activate
            cd /home/ec2-user/app/
            pip install -r requirments.txt
            sudo systemctl restart flaskapp.service
          EOF
          '''
      }
    }
  }
}
```

- Save the Jenkinsfile and push it to GitHub repo.

- As GitHub repo is configured with Webhook to call Jenkins Server, pushing Jenkinsfile to GH will trigger the Jenkins job and Deploy the application to the server.

## Access the deployed Python Application

- Navigate to the browser and hit the endpoint: `http://appserver-ip-address:5000`

- As the application is listening on port 5000, you should see the application landing page

## Recommended Enhancements

- You may add an additional stage for performing static code analysis using tools like sonarqube.
- You may push the build artifact (package) in artifactory tools like nexus or JFrog followed by app deployment.
