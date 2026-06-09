# Hands-on Lab: Integrate Sonatype Nexus with Jenkins for Artifact Management

## Prerequisites

- Complete Jenkins CI Labs - part1, part2, and part3

## Step-01: Setting-up Sonatype Nexus Server (on Amazon Linux 2023)

### Create an EC2 Instance

- Sign-in to AWS Account (https://console.aws.amazon.com/).
- Navigate to EC2 service >> **Launch Instance**.
- **Name**: nexus-server-local
- **AMI**: Amazon Linux 2023 6.1 Kernel
- **Instance Type**: t3.medium
- **Key Pair**: <create_new_keypair_or_select_existing>
- **VPC and Subnet**: Default
- **Public IP**: Enable
- **Security Group**:
  - **Name**: nexus-server-sg
  - **Ingress**: Allow 22 (SSH), 8081 (Nexus web UI)
- **Storage**: 15 GB, GP2 (min for this lab)
- Click on **Launch Instance** button

### Download and Extract Nexus

- Install Java

```bash
# Update existing packages
sudo dnf update -y

# Install Java 21
sudo dnf install -y java-21-amazon-corretto-devel

# Verify the Java installation
java --version
```

- Download and Extract Nexus (https://help.sonatype.com/en/download.html)

```bash
cd /opt

sudo wget https://download.sonatype.com/nexus/3/nexus-3.93.0-06-linux-x86_64.tar.gz

sudo tar -xvf nexus-3.93.0-06-linux-x86_64.tar.gz

# Rename the extracted folder to a simplified name
sudo mv nexus-3.93.0-06 nexus
```

### Create and configure a dedicated System user for Nexus

- For system security, running applications like _Nexus_ under root privileges is not advised.
- Runs the Nexus Java process on the server.
- Manages local directories like `/opt/nexus`.

- Create a dedicated service user for Nexus and assign ownership:

```bash
sudo adduser nexus
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work
```

> [!NOTE]
> The extraction automatically creates the data folder /opt/sonatype-work right alongside the application directory.

- Instruct Nexus to execute as your new user by uncommenting and editing the parameter inside `/opt/nexus/bin/nexus.rc`

```bash
sudo vi /opt/nexus/bin/nexus.rc

# Uncomment and edit the following parameter to read
run_as_user="nexus"
```

### Configure Nexus as a Systemd Service

- Create a systemd startup script so you can manage the Nexus lifecycle:

```bash
sudo vi /etc/systemd/system/nexus.service

# Add the following contents to the unit file
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

- Reload systemd configurations and trigger the background initialization:

```
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl restart nexus
```

### Access the Nexus UI and Retrieve Admin Password

- The preceding commands will start the nexus service on port 8081.
- To access the nexus dashboard, visit:

```
http://nexus-server-public-ip-or-dns:8081
```

- You will be able to see the Nexus Dashboard login page. To sign-in, use the following credentials:
  - Username: `admin`
  - Password: `run-following-cmd-to-retrieve-temp-pwd`

    ```
    sudo cat /opt/sonatype-work/nexus3/admin.password
    ```

- Now, you should land on your personalize Nexus Dashboard page.

### Create and configure a local Nexus User for Jenkins integration

#### Create a Role in Nexus

- This step defines what Jenkins is allowed to do in Nexus (add and edit artifacts in your Maven repositories).

- Log into your Nexus 3 dashboard as an admin.
- Click the Administration cog icon (top menu bar).
- Navigate to Security > Roles in the left sidebar.
- Click Create role and select Nexus role.
- Fill out the following details:
  1. **Role ID**: `jenkins-deployer`
  2. **Name**: Jenkins Deployer Role
  3. **Description**: Allows Jenkins to upload Maven artifacts

- In the Privileges section, use the filter box to find and add these exact permissions:
  - nx-repository-view-maven2-\*-add (Allows uploading new artifacts)
  - nx-repository-view-maven2-\*-edit (Allows overwriting or updating snapshots)
  - nx-repository-view-maven2-\*-read (Allows Jenkins to view existing components)
  - nx-repository-view-maven2-\*-browse (Allows viewing files in the UI index)

- Click **Create role**

#### Create a local User Account in Nexus and assign Role

- This step creates the actual credentials Jenkins will use to log in to Nexus.
- In the left sidebar, navigate to Security > Users.
- Click Create local user.
- Fill out the user profile details:
  - ID: `jenkins-svc` (this will be the username in Jenkins)
  - First Name: Jenkins
  - Last Name: Service
  - Email: jenkins@yourcompany.com
  - Status: Set to Active
  - Password: Enter a strong, unique password
- Scroll down to the **Roles** section &rarr; find `jenkins-deployer` under **Given** or **Available roles** and move it to the **Given** side.

- Click **Create local user**.

#### Save the Nexus User details to Jenkins

- Now that the account exists in Nexus, securely store it inside Jenkins so your pipelines can access it.

- Log into your Jenkins dashboard.
- Navigate to **Manage Jenkins** &rarr; Credentials &rarr; System &rarr; Global credentials (unrestricted).
- Click **Add Credentials**.
- Configure the fields exactly like this:
  - **Kind**: Username with password
  - **Scope**: Global
  - **Username**: `jenkins-svc` (The exact Nexus User ID you created)
  - **Password**: (The password you set for jenkins-svc)
  - **ID**: `nexus-credentials-id` (Use this exact string in your pipeline script)
  - **Description**: Nexus 3 deployment service account
- Click **Create**

## Step-02: Integrate Nexus with Jenkins Pipeline

### Install Plugins in Jenkins

- Jenkins Dashboard &rarr; **Manage Jenkins** &rarr; Plugins &rarr; Available Plugins. Search the following plugins and install
  1. _Sonatype Platform Plugin_
  2. _Pipeline Utility Steps Plugin_ (it provides the _readMavenPom_ step)

### Save the Nexus Server connectivity details under Jenkins System Configurations

- Navigate to Manage Jenkins → System.
- Scroll down to find the **Sonatype Nexus configuration** block.
- Click **Add Nexus Repository Server** and select **Nexus Repository Server**.
- Fill in the parameters exactly as follows:
  - Display Name: Nexus Production Server
  - Server ID: `nexus-production` (Take note of this; it must match the ID in your Jenkinsfile)
  - Server URL: http://<YOUR_NEXUS_SERVER_IP_OR_DNS>:8081
  - Credentials: `nexus-credentials-id`
- Click **Test Connection** to ensure Jenkins can reach your server &rarr; Click **Save** button.

### Update the Jenkins Pipeline Script (Jenkinsfile) for Uploading artifacts to Nexus

- This declarative pipeline uses java21 to build a Maven application.
- It incorporates the _Pipeline Utility Steps Plugin_ to automatically read your project's **groupId**, **artifactId**, and **version** directly from your pom.xml file.
- It dynamically parses the project information via _readMavenPom_, and publishes the final .jar artifact to Nexus using the _nexusPublisher_ step.

```groovy
pipeline {
    agent any

    tools {
        // must match your Java 21 tool configuration name in "Tools" section
        jdk 'java-21'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Pull source from your repository control system
                git branch: 'main', url: 'https://github.com'
            }
        }

        stage('Build & Test') {
            steps {
                // Clean package compiling via Java 21 framework
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Read POM File & Build') {
            steps {
                script {
                    // Read Maven metadata using the Pipeline Utility Steps Plugin
                    def pom = readMavenPom file: 'pom.xml'

                    // Assign pom properties to environment variables for cross-stage access
                    env.POM_GROUP_ID   = pom.groupId ?: pom.parent.groupId // Fallback to parent groupId if missing
                    env.POM_ARTIFACT   = pom.artifactId
                    env.POM_VERSION    = pom.version

                    echo "Successfully parsed POM data:"
                    echo "Group ID: ${env.POM_GROUP_ID}"
                    echo "Artifact ID: ${env.POM_ARTIFACT}"
                    echo "Version: ${env.POM_VERSION}"
                }

                // Compile the Java app into a .jar file
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Upload to Nexus 3') {
            steps {
                script {
                    // Dynamically toggle repository destination based on version suffix
                    def targetRepo = env.POM_VERSION.endsWith("-SNAPSHOT") ? 'maven-snapshots' : 'maven-releases'
                    echo "Target Repository selected: ${targetRepo}"

                    // Execute upload using Sonatype Platform Plugin step
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        nexusInstanceId: "${env.NEXUS_INSTANCE_ID}",
                        repository: targetRepo,
                        artifacts: [
                            [
                                artifactId: "${env.POM_ARTIFACT}",
                                groupId: "${env.POM_GROUP_ID}",
                                version: "${env.POM_VERSION}",
                                type: 'jar',
                                classifier: '',
                                // Dynamically targets the generated JAR file in the target folder
                                file: "target/${env.POM_ARTIFACT}-${env.POM_VERSION}.jar"
                            ]
                        ]
                    )
                }
            }
        }
    }

    post {
        success {
            echo "Successfully pushed ${env.POM_ARTIFACT}-${env.POM_VERSION}.jar to Nexus!"
        }
        failure {
            echo 'Pipeline deployment failed. Check Nexus permissions or network connectivity.'
        }
    }
}
```

## Step-03: Push the changes to GitHub (SCM)

## Step-04: Create a Jenkins Job (pipeline)

## Step-05: Verify the results | Pipeline | Artifacts on Nexus
