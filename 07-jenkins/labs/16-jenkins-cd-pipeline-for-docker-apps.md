# Hands-on Lab: Deploying Containerised Maven Apps to Remote Docker Hosts (Test/Prod)

## Prerequisites

- Jenkins Server with the following tools configured:
  - Git
  - Maven
  - Java
- GitHub Repo with a Maven project
- DockerHub Account

## Configure Jenkins Server

### Install Plugins

- Docker Pipeline
- Pipeline Stage View
- SSH Agent

### Install Tools

#### Install Docker Engine

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

### Verify Docker on Jenkins

- Once Jenkins restarts, you can run this command to verify that the jenkins user can interact with the Docker daemon successfully:

```bash
sudo su - jenkins -s /bin/bash -c "docker info"

# If you see system configuration outputs instead of a "permission denied" error, your access setup is complete
```

## Generate DockerHub Access token (PAT) and Save it on Jenkins

- Type: Username and Password
- ID: `dockerhub-creds`

## Setup Target Server (Docker Host)

### Install and Configure Docker

- Ensure Docker is running.

### Create a new user and add it to the Docker group

- Username: jenkins-deploy

```bash
sudo adduser jenkins-deploy

sudo usermod -aG docker jenkins-deploy
```

### Generate SSH key pair on Jenkins for deployment on the Remote server (Docker)

- Because the jenkins user has no login shell, you must generate the keys by explicitly passing the path and the user context:

```bash
sudo -u jenkins -s /bin/bash -c "ssh-keygen -t ed25519 -f /var/lib/jenkins/.ssh/id_ed25519 -N ''"
```

### Configure the SSH Public key on the Remote server (Docker)

- You need to copy the public key you just generated and place it on the remote deployment server.
- View and copy the public key from your Jenkins master by running the following command:

```bash
sudo cat /var/lib/jenkins/.ssh/id_ed25519.pub
```

- Log into your remote server &rarr; Switch to the new user (jenkins-deploy), set up the SSH directory, and append your pre-existing Jenkins public key (usually an .pub file) into the authorized_keys file:

```bash
sudo su - jenkins-deploy

mkdir -p ~/.ssh

sudo chmod 700 ~/.ssh

echo "your-jenkins-public-key-string-here" >> ~/.ssh/authorized_keys

sudo chmod 600 ~/.ssh/authorized_keys

sudo chown -R jenkins-deploy:jenkins-deploy ~/.ssh
```

### Save the Remote Server Private Key on Jenkins

- Jenkins cannot read the file from `/var/lib/jenkins/.ssh/` during a pipeline job unless it is explicitly added to the Jenkins Credential Store.

- Print the private key (which you will need to copy and paste into the Jenkins Web UI credentials manager):

```bash
sudo cat /var/lib/jenkins/.ssh/id_ed25519
```

- Open your **Jenkins Dashboard** ➔ **Manage Jenkins** ➔ **Credentials** ➔ System ➔ Global credentials (unrestricted)
- Click **Add Credentials** and fill out the form:
  - **Kind**: SSH Username with private key
  - **ID**: remote-server-ssh
  - **Username**: jenkins-deploy (the exact name of the user on the remote server)
  - **Private Key**: Check Enter directly, click Add, and paste the entire private key block (including the -----BEGIN OPENSSH PRIVATE KEY----- and -----END OPENSSH PRIVATE KEY----- lines)

- Click **Create**

### (Optional) Test the Connection

- To verify everything works flawlessly, you can create a test Jenkins Pipeline job using this snippet:

```groovy
pipeline {
    agent any

    environment {
        // REPLACE THESE PLACEHOLDERS WITH YOUR ACTUAL DETAILS
        REMOTE_USER = 'jenkins-deploy'
        REMOTE_IP   = '192.168.1.50'
        SSH_CRED_ID = 'remote-server-ssh'
    }

    stages {
        stage('Test SSH Connection') {
            steps {
                // Requires the 'SSH Agent' plugin installed in Jenkins
                sshagent(["${env.SSH_CRED_ID}"]) {
                    // Uses the placeholders defined in the environment block
                    sh 'ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP} "echo Connection Successful!"'
                }
            }
        }
    }
}
```

## Create a Dockerfile

- To make sure the Maven output asset builds accurately into your image layer, utilize a minimal multi-stage Dockerfile similar to this in your code repository:

```
# --- Stage 1: Build execution layer matching Maven 3.9.16 and Java 21 ---
FROM maven:3.9.16-eclipse-temurin-21-alpine AS builder
WORKDIR /build
COPY pom.xml .

# Fetch dependencies to cache this layer independently
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# --- Stage 2: Minimal Java 21 runtime image ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Pull down built .jar resource from builder stage
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Create a Jenkins Pipeline (Jenkinsfile)

- Place this Jenkinsfile at the root of your Maven application repository.
- It compiles your code, containerizes the artifact, uploads it to an image repository, and remotely forces the separate machine to update the container.

```groovy
pipeline {
    agent any

    environment {
        // Centralized Jenkins Credential IDs
        DOCKERHUB_CREDS_ID = 'dockerhub-creds'
        SSH_HOST_CREDS_ID  = 'remote-server-ssh'

        // Docker Hub Registry Naming
        DOCKER_IMAGE_NAME  = 'your-dockerhub-username/maven-java21-app'
        IMAGE_TAG          = "${BUILD_NUMBER}"

        // Remote Docker Host Information (Target separate machine)
        SSH_TARGET_HOST    = '192.168.1.50'
        SSH_TARGET_USER    = 'ubuntu'
        CONTAINER_NAME     = 'maven-java21-app'
        HOST_PORT          = '8080'
        CONTAINER_PORT     = '8080'
    }

    stages {
        stage('Clone Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Maven Package') {
            steps {
                withMaven(maven: 'Maven-3.9.16', jdk: 'JDK-21') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                // Referencing the Docker Hub credentials environment variable
                withCredentials([usernamePassword(credentialsId: "${env.DOCKERHUB_CREDS_ID}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                    sh "docker push ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to Remote Docker Host') {
            steps {
                // Referencing the SSH key credentials environment variable
                sshagent(["${env.SSH_HOST_CREDS_ID}"]) {
                    withCredentials([usernamePassword(credentialsId: "${env.DOCKERHUB_CREDS_ID}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${SSH_TARGET_USER}@${SSH_TARGET_HOST} '
                                echo ${PASS} | docker login -u ${USER} --password-stdin

                                docker pull ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}

                                if [ \$(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                                    docker stop ${CONTAINER_NAME}
                                    docker rm ${CONTAINER_NAME}
                                fi

                                docker run -d \
                                    --name ${CONTAINER_NAME} \
                                    -p ${HOST_PORT}:${CONTAINER_PORT} \
                                    --restart always \
                                    ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}

                                docker logout
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker rmi ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest || true"
            sh "docker logout"
        }
    }
}
```

## Create and Trigger Jenkins Job

## Verify the deployed Application
