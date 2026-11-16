# Hands-on Lab: Create a Jenkins based Continuous Delivery (CD) pipeline for building and deploying a Maven App on EC2 Instance

- In this lab, you will setup a Jenkins based Continuous Delivery (CD) pipeline for Maven application.
- A production-grade Jenkins pipeline is written as Pipeline as Code via a Jenkinsfile and strictly separated from configuration data.

> [!IMPORTANT]
> Jenkins Pipeline must be resilient, modular, secure, and clear, leveraging native declarative directives rather than custom scripting blocks.

This Jenkins CD pipeline splits the workflow into distinct, sequential, and parallel blocks to enforce a "fail-fast" paradigm:

1. **Initialize**
   - Validates environment paths, tools, and pulls environment metadata.
     </br>&darr;

- **Compile & Test**
  - Builds the Maven binaries and runs Unit/Integration tests.
    </br>&darr;
- **Static Code Analysis (Linting/SCA)**
  - Scans source code for quality gates, security vulnerabilities (e.g., SonarQube), and credential leaks before compilation.
    </br>&darr;
- **Security Scanning (Dependency Check)**
  - Audits open-source software (OSS) dependencies for known CVE vulnerabilities.
    </br>&darr;
- **Publish Artifact**
  - Pushes the tested, immutable package (e.g., .jar, .war, or Docker image) to a private repository (Nexus or JFrog Artifactory).
    </br>&darr;
- **Deploy to Staging Environment**
  - Deploys the package to a pre-production/staging environment automatically.
    </br>&darr;
- **Automated Smoke Test**
  - Runs a quick test suite against the live staging environment to verify stability.
    </br>&darr;
- **Promote to Production**
  - A gated, time-bound stage requiring authorized human intervention before releasing live.

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
   - **Purpose**: Provides the withSonarQubeEnv wrapper and the `waitForQualityGate` step. It allows Jenkins to communicate with your SonarQube server and pause the build until the quality check finishes.
3. **SSH Agent Plugin**
   - **Purpose**: Provides the sshagent block wrapper. This safely loads your EC2 private key credentials into memory so scp and ssh commands can run without exposing keys on the disk. Also, to use the `sshagent` block in a _Jenkinsfile_.
4. **Pipeline: Maven Integration Plugin**
   - **Purpose**: Adds native support for the tools { maven '...' } block. This automates the downloading, path configurations, and provisioning of specific Maven installations directly inside the script pipeline.
5. **Credentials Binding Plugin**
   - **Purpose**: Provides the `withCredentials` step syntax. This safely injects hidden secrets (like your sonar-token) as masked environment variables into individual shell script scopes.

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

- For many interpreted languages (like JavaScript or Python), we run static code analysis directly on raw source code files. However, Java is a compiled language, and **SonarQube** explicitly requires compiled bytecode (.class files) to perform accurate analysis.

> [!IMPORTANT]
> Initialize Pipeline &rarr; Compile & Unit Test &rarr; Security & Quality Analysis &rarr; Publish Artifact &rarr; Deploy to Staging &rarr; Smoke Test &rarr; Production Gate &rarr; Deploy to Production

- Lets, create a production-grade pipeline:

```groovy
pipeline {
    agent any

    options {
        timeout(time: 2, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '30'))
        disableConcurrentBuilds()
        skipStagesAfterUnstable()
    }

    tools {
        // Names must exactly match your 'Manage Jenkins' -> 'Tools' definitions
        maven 'maven-3.9.15'
        jdk   'java-21'
        sonarScanner 'sonar-scanner'
    }

    environment {
        APP_NAME         = 'maven-enterprise-app'   // SQ Project Key
        SQ_ORG_NAME      = 'bin-org'
        NEXUS_REPO_URL   = 'https://company.com'
        SONARQUBE_SERVER = 'sonarqube-server' // Matches the name defined under Jenkins System Configuration
        STAGING_SERVER   = '10.0.12.45'
        PROD_SERVER      = '10.0.14.90'

        SONAR_TOKEN      = credentials('sonar-server-token')
        SSH_DEPLOY_KEY   = credentials('ssh-prod-deploy-key')
        PROD_DEPLOY_APPROVERS = 'jenkinsadmin' // Jenkins usernames
    }

    stages {
        // Verifies environment readiness, prints tool versions and logs build metadata for audit trails.
        stage('Initialize') {
            steps {
                echo "Starting build sequence for ${env.APP_NAME} - Build Number: ${env.BUILD_NUMBER}"
                sh 'mvn --version'
            }
        }

        // Compiles Java source files into bytecode and runs unit tests.
        stage('Compile & Unit Test') {
            steps {
                echo 'Compiling code and generating test coverage reports...'
                // Generates target/classes and target/surefire-reports
                sh 'mvn clean test'
            }
            post {
                success {
                    // Publishes test results immediately to the Jenkins UI dashboard
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        // Runs code quality scans and open-source dependency auditing simultaneously to minimize total pipeline execution time.
        stage('Security & Quality Analysis') {
            parallel {
                stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv("${env.SONARQUBE_SERVER}") {
                            sh "mvn sonar:sonar -Dsonar.projectKey=${env.APP_NAME} -Dsonar.login=${SONAR_TOKEN}" -Dsonar.organization=${env.SQ_ORG_NAME}
                        }
                    }
                }
                stage('OWASP Dependency Check') {
                    steps {
                        echo 'Scanning open-source dependencies for known CVE flaws...'
                        sh 'mvn dependency-check:check'
                    }
                }
            }
        }

        // This stage verifies if the SonarQube analysis passed the Quality Gate thresholds
        // Pauses the pipeline to wait for SonarQube server analysis results.
        // Fails the build automatically if quality thresholds (bugs, coverage) are missed.
        stage('SonarQube Quality Gate') {
            steps {
                echo 'Checking SonarQube Quality Gate status...'
                // Explicitly wrap only the listener step in a clear timeout block
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to SonarQube Quality Gate Failure. Status: ${qg.status}"
                        }
                    }
                }
            }
        }

        // Packages verified bytecode into a final deployable artifact (.war/.jar) and uploads it securely to the Nexus repository.

        stage('Package & Publish') {
            steps {
                echo "Packaging final artifact and publishing to ${env.NEXUS_REPO_URL}"
                // Reuses compiled classes to build the final deployable artifact safely
                withCredentials([usernamePassword(credentialsId: 'nexus-deployer-account', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh "mvn deploy -DaltDeploymentRepository=nexus::default::${env.NEXUS_REPO_URL} -Dusername=${NEXUS_USER} -Dpassword=${NEXUS_PASS} -DskipTests=true"
                }
            }
        }

        // Copies the newly published artifact onto the staging application server using secure shell authentication.

        stage('Deploy to Staging') {
            steps {
                echo "Deploying out to Staging Node: ${env.STAGING_SERVER}"
                sh "scp -i ${SSH_DEPLOY_KEY} target/*.war ubuntu@${env.STAGING_SERVER}:/opt/tomcat/webapps/"
            }
        }

        // Runs basic live endpoint checks against the staging deployment to confirm the application started up successfully without runtime crashes.

        stage('Smoke Test') {
            steps {
                echo 'Validating environment health check endpoints...'
                sh "curl --fail http://${env.STAGING_SERVER}:8080/${env.APP_NAME}/health || exit 1"
            }
        }

        // Enforces a manual approval step for authorized users before production release.
        // Includes a 1-day timeout to prevent idle builds from tying up pipeline queues indefinitely.

        stage('Gate to Production') {
            steps {
                timeout(time: 1, unit: 'DAYS') {
                    input message: "Approve deployment of version ${env.BUILD_NUMBER} directly to Production?",
                          submitter: "${env.PROD_DEPLOY_APPROVERS}"
                }
            }
        }

        // Executes the final code release to the production live system cluster after passing all automated and human quality gates.

        stage('Deploy to Production') {
            steps {
                echo "Executing release pipeline on production node: ${env.PROD_SERVER}"
                sh "scp -i ${SSH_DEPLOY_KEY} target/*.war ubuntu@${env.PROD_SERVER}:/opt/tomcat/webapps/"
            }
        }
    }


    post {
        always {
            echo 'Executing workspace cleanup...'
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed at build number ${env.BUILD_NUMBER}."
        }
    }
}
```

## Step-XX: Update the `pom.xml` file

- include mainClass block
- Java version
- include Binary Name

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
