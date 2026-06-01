# Hands-on Lab: Create a Jenkins based Continuous Delivery (CD) pipeline for building and deploying a Maven App on EC2 Instance

- In this lab, you will setup a Jenkins based Continuous Delivery (CD) pipeline for Maven application.

## Prerequisites

- A _Jenkins_ server with admin privileges and with following tools configured:
  - git
  - java (21+)
  - maven
- A _GitHub_ account
- A _Github repository_ (private) with a Maven Project

## Step-XX: Create and Configure a Test Environment (here EC2 Instance)

### Configure Test Server (EC2) Security Group for Java Application

#### `Inbound Rules`

| Type       | Protocol | Port Range              | Source Type       | Source / IP                                            | Purpose                                                       |
| ---------- | -------- | ----------------------- | ----------------- | ------------------------------------------------------ | ------------------------------------------------------------- |
| SSH        | TCP      | 22                      | Custom            | Jenkins-Server-Public-IP /32 **or** 0.0.0.0/0 (Public) | Allows Jenkins to securely run scp and ssh commands.          |
| Custom TCP | TCP      | 8080 (or your app port) | My IP or Anywhere | 0.0.0.0/0 (Public) or Your-IP/32                       | Allows you to access your running Java application test page. |

#### Outbound Rule

- Leave the default Outbound Rules set to **All Traffic (0.0.0.0/0)** so your EC2 instance can freely fetch system security updates.

### Install necessary tools

1. Java Runtime Environment (JRE/JDK)

2. OpenSSH Server (Usually Pre-installed)

### Configure Application Directory

- To prevent permission errors when Jenkins runs the **scp** command, create the target deployment path specified in your Jenkinsfile (/var/www/app) and hand over ownership to your deployment user (e.g., jenkins).

```bash
# Create the deployment directory path
sudo mkdir -p /var/www/app

# Change ownership of the directory to the ubuntu user
sudo chown -y jenkins:jenkins /var/www/app
```

### Create a new User for Jenkins deployments

- For production or team environments, you should create a restricted, dedicated user (e.g., jenkins-deploy).
- This isolates Jenkins' access strictly to the application directories.

```bash
# Create the user and home directory
sudo useradd -m -s /bin/bash jenkins

# Switch to jenkins user
sudo su - jenkins

# Generate a secure ED25519 or RSA key pair (press Enter through all prompts to leave the passphrase empty)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins_key

# Authorize the Public Key on EC2
cat ~/.ssh/jenkins_key.pub >> ~/.ssh/authorized_keys

# Set strict file permissions so SSH does not reject the keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Configure Application as a Systemd Service (optional but recommended)

- To ensure your application automatically runs in the background and restarts if the EC2 instance reboots, configure it as a system service.

```bash
# Create a service file
sudo vi /etc/systemd/system/my-java-app.service

# Paste the following contents into the above file
[Unit]
Description=My Java Maven Application
After=network.target

[Service]
User=jenkins
WorkingDirectory=/var/www/app
ExecStart=/usr/bin/java -jar /var/www/app/app.jar
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## Step-XX: Configure Jenkins Server

### Install required plugins

1. **Pipeline: Stage View Plugin**
   - **Purpose**: Visualizes each stage (Build, SonarQube Analysis, Deploy) on your Jenkins dashboard dashboard, making it easy to track build progress and trace failures.
2. **SonarQube Scanner for Jenkins**
   - **Purpose**: Provides the withSonarQubeEnv wrapper and the waitForQualityGate step. It allows Jenkins to communicate with your SonarQube server and pause the build until the quality check finishes.
3. **SSH Agent Plugin**
   - **Purpose**: Provides the sshagent block wrapper. This safely loads your EC2 private key credentials into memory so scp and ssh commands can run without exposing keys on the disk.
4. **Pipeline: Maven Integration Plugin**
   - **Purpose**: Adds native support for the tools { maven '...' } block. This automates the downloading, path configurations, and provisioning of specific Maven installations directly inside the script pipeline.
5. **Credentials Binding Plugin**
   - **Purpose**: Provides the `withCredentials` step syntax. This safely injects hidden secrets (like your sonar-token) as masked environment variables into individual shell script scopes.

6. **SSH Agent Plugin**
   - **Purpose**: To use the `sshagent` block in a Jenkinsfile.

### Configure Tools

1. Git
2. Java
3. Maven

### Save Credentials of GitHub

### Save Credentials of Test Environment (SSH key)

- SSH to your Test Server (EC2) and copy the _SSH private key_ contents by running the following command:

```bash
# copy the private key contents to your clipboard
cat ~/.ssh/jenkins_key
```

- Save the SSH private key to Jenkins
  - Open your Jenkins Dashboard.
  - Navigate to Manage Jenkins &rarr;
    Credentials &rarr; System &rarr; Global credentials (unrestricted).
  - Click **Add Credentials** on the top right. Configure the fields exactly like this:
    - **Kind**: SSH User Private Key
    - **ID**: ec2-ssh-key (This must exactly match the ID used in your Jenkinsfile)
    - **Description**: EC2 Deployment Key
    - **Username**: jenkins (The exact user account created on EC2)
    - **Private Key**: Check Enter directly, click Add, and paste your entire copied private key text block here.

  - Click **Create**

## Step-XX: Create a `Jenkinsfile`

## Step-XX: Update the pom.xml file

## Step-XX: Create a GitHub Webhook for Jenkins

## Step-XX: Push the changes to GitHub

## Step-XX: (optional) Verify SSH connection between Jenkins server and Test server

- To verify that your SSH key authentication is configured correctly before running your full pipeline, you can run a quick diagnostic test using a temporary Jenkins Pipeline job

```groovy
pipeline {
    agent any
    stages {
        stage('Test SSH Connection') {
            steps {
                // Ensure 'ec2-ssh-key' matches your exact credential ID in Jenkins
                sshagent(credentials: ['ec2-ssh-key']) {
                    echo "Attempting secure connection to EC2..."

                    // Runs an automated 'echo' command inside the remote EC2 terminal
                    sh """
                        ssh -o StrictHostKeyChecking=no jenkins@192.168.1.50 'echo "✅ Connection Successful! Running as user: \$(whoami)"'
                    """
                }
            }
        }
    }
}

[IMPORTANT: Make sure to change 192.168.1.50 to your actual test server (EC2) Public IP Address]
```

- Click **Save**, then click **Build Now**.
- Open the Console Output of the build. If successful, you will see:

```bash
Attempting secure connection to EC2...
✅ Connection Successful! Running as user: jenkins-deploy
Finished: SUCCESS
```

## Step-XX: Create Jenkins Job (pipeline)

## Step-XX: Trigger the Jenkins Pipeline

## Step-XX: Verify the App Deployment

## Troubleshooting Common Connection Issues

```bash

# If your test build fails, match the console error output to these fixes:

Error: Host key verification failed.
Fix: You forgot to include -o StrictHostKeyChecking=no in your ssh command string. Jenkins runs non-interactively and cannot manually type "yes" to accept new remote host keys.
--------------------------
Error: Permission denied (publickey).
Fix 1: The username in your Jenkins Credential entry does not match the EC2 user. Ensure the username field in Jenkins is explicitly set to jenkins-deploy.
Fix 2: The public key wasn't properly appended. Log back into EC2 and verify your public key format by running cat ~/.ssh/authorized_keys. It must be a single, continuous line starting with ssh-rsa.
---------------------------------
Error: Connection timed out or Network is unreachable
Fix: Your AWS EC2 Security Group is blocking incoming traffic. Go back to AWS and verify that your Inbound Rules explicitly allow Port 22 from your Jenkins Server's public IP address.
```
