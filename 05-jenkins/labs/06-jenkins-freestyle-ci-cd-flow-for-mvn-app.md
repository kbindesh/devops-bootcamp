# Hands-on Lab: Configure Jenkins Server for building Maven Applications

## Prerequisites

- AWS Account
- Jenkins Server
- GitHub Account
- GitHub Repository with the following:
  - Maven project code (on main branch)
  - Webhook to Jenkins server

## Step-01: Configuring Jenkins Server for building Maven App

### 1.1: Install Plugins

- Navigate to Jenkins dashboard >> **Manage Jenkins** >> **Plugins** >> **Available Plugins**
- Search and Install following plugins:
  - _Maven Integration_
  - _Maven Invoker_
  - _GitHub_
  - _SSH Agent Plugin_

### 1.2: Integrate GitHub with Jenkins | Generate GitHub Credential (PAT) and Configure it on Jenkins

- **Generate GitHub Personal Access Token (PAT) for Jenkins**
  - Sign in to your GitHub account.
  - Click on your profile picture in the upper-right corner &rarr; **Settings** &rarr; **Developer settings** &rarr; **Personal Access Tokens** &rarr; **Tokens (classic)**
  - Click **Generate new token** &rarr; **Generate new token (classic)**
    - **Note**: token-for-jenkins
    - **Expiration**: 30 days
    - **Select Scope**: Check `repo` section
    - Click on **Generate token** button.
  - Copy the token to your clipboard.

> [!IMPORTANT]
> You won't be able to see this token again, so store it securely somewhere.

- **Save the GitHub PAT on Jenkins**
  - Navigate to **Manage Jenkins** &#8594; **Credentials**.
  - Select the **(global) domain** or the specific domain for your project &#8594; **Add Credentials**.
    - **Kind**: Username with password.
    - **Username**: <YOUR_GITHUB_USERNAME>
    - **Password**: <GITHUB_PAT>
    - **ID**: github-credentials
    - **Description**: GitHub authN credentials

  - Click **Create** button.

### 1.3: Install and Configure `Java`

- Official link for java download: https://www.oracle.com/in/java/technologies/downloads/

- You must be already having Java installed on your Jenkins server (prerequisite for Jenkins). If already present, you may skip the installation related command:

```
# Switch to root user
sudo su -

# Update system packages
dnf update -y

# Install Java (JDK-21)
dnf install -y java-21-amazon-corretto-devel

# Verify java installation
java --version
```

- **Setup JAVA_HOME path with java home directory location**

```
find /usr/lib/jvm/java* | head -n 3
[From the preceding command, copy "/usr/lib/jvm/java-21-amazon-corretto" path]

vi ~/.bash_profile

# Create a new variable JAVA_HOME
JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto

# Add JAVA_HOME to the existing path
PATH=$PATH:$HOME/bin:$JAVA_HOME
```

- **Verify the Java path**

```
echo $PATH
[The preceding command will give you the updated PATH]

# In order to refresh the path
source ~/.bash_profile

# Again, display the PATH to get the updated values
echo $PATH
```

### 1.4: Install and Configure `Maven`

- Apache maven official download page: https://maven.apache.org/download.cgi

- Download and configure Apache Maven:

```
# Move to /opt directory
cd /opt

# Download the maven binary
sudo wget https://dlcdn.apache.org/maven/maven-3/3.9.16/binaries/apache-maven-3.9.16-bin.tar.gz

# Unzip the downloaded maven tarball
sudo tar -xvf apache-maven-3.9.16-bin.tar.gz

# List all the file to see the unzipped maven directory
ls -l apache-maven-3.9.16

# Get inside the maven home directory
cd apache-maven-3.9.16
```

- **Setup MAVEN HOME path | M2_HOME & M2 variables**

```
# Update the bash profile with maven path
vi ~/.bash_profile

# Create M2_HOME and M2 variable with maven location specs
M2_HOME=/opt/apache-maven-3.9.16
M2=/opt/apache-maven-3.9.16/bin

# Update the PATH variable | Add Maven path
PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2

[Save the file and exit]

source ~/.bash_profile

# Verify the PATH with java and maven variables
echo $PATH
```

### 1.5: Configure `Maven` and `Java` installation path on Jenkins

- Navigate to Jenkins server dashboard >> Manage Jenkins >> Tools

- **JDK**
  - Name: java-21
  - JAVA_HOME: /usr/lib/jvm/java-21-amazon-corretto

- **Maven** - location of maven installation on Maven Agent machine (not on Jenkins master node)
  - Name: maven-3.9.16
  - MAVEN_HOME: /opt/apache-maven-3.9.16

### 1.6: Install `Git`

```bash
sudo dnf install -y git
```

## Step-02: Create and Configure a Test Server (here EC2 Instance)

### Create a Test Server (EC2 Instance)

- Sign-in to AWS Account (https://console.aws.amazon.com/).
- Navigate to EC2 service &rarr **Launch Instances**.
  - Name: TEST-SERVER
  - AMI: Amazon Linux 2023 6.1 Kernel
  - Instance Type: t2.micro
  - Key Pair: <create_new_keypair>
  - VPC/Subnet: Default
  - Elastic IP: Enable
  - Security Group:
    - Name: test-server-sg
    - Ingress: Allow 22 (SSH)
  - Storage: 15 GB, GP2 (min for this lab)
- Click on **Launch Instance** button

### Install Tools

1. Java Runtime Environment (JRE/JDK 21 or above)

2. OpenSSH Server (Usually Pre-installed)

### Create a new User for Jenkins deployments

- For production or team environments, you should create a restricted, dedicated user (e.g., jenkins-deploy).
- This isolates Jenkins' access strictly to the application directories.

```bash
sudo su -

# Create the user and home directory
useradd -m -s /bin/bash jenkins

# Add "jenkins" user to the sudoers group
visudo

# Scroll all the way to the "Allow root to run any command anywhere" section and add jenkins user after the root user entry

root    ALL=(ALL)     ALL
jenkins ALL=(ALL)     NOPASSWD: ALL

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

### Configure Application Directory

- To prevent permission errors when Jenkins runs the **scp** command, create the target deployment path specified in your Jenkinsfile (/var/www/app) and hand over ownership to your deployment user (e.g., jenkins).

```bash
# Create the deployment directory path
sudo mkdir -p /var/www/app

# Change ownership of the directory to the "jenkins" user
sudo chown jenkins:jenkins /var/www/app
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

- Enable the service:

```
systemctl enable my-java-app.service
```

## Step-03: Save Test Server login Credentials (SSH keys) on Jenkins

- SSH to your Test Server (EC2) and copy the _SSH private key_ contents by running the following command:

```bash
# copy the private key contents to your clipboard
cat ~/.ssh/jenkins_key
```

- Save the SSH private key to Jenkins
  - Open your _Jenkins Dashboard_.
  - Navigate to **Manage Jenkins** &rarr; **Credentials** &rarr; **System** &rarr; **Global credentials (unrestricted)**.
  - Click **Add Credentials** on the top right. Configure the fields exactly like this:
    - **Kind**: SSH User Private Key
    - **ID**: test-server-ssh-key (This must exactly match the ID used in your Jenkinsfile)
    - **Description**: Test Server Deployment SSH Key
    - **Username**: jenkins (The exact user account created on EC2)
    - **Private Key**: Check Enter directly, click **Add**, and paste your entire copied private key text block here.

  - Click **Create**

## Step-04: Save Test Server details on Jenkins (System)

- Before configuring the individual job, Jenkins needs global permission to SSH into your Test server (destination).

- Log in to Jenkins and navigate to Manage Jenkins &rarr; System (formerly _Configure System_).
- Scroll to the bottom to find the **Publish over SSH section**

- Under **SSH Servers**, click **Add**. Configure your instance credentials:
  - Name: Provide a nickname (e.g., Test-Server)
  - Hostname: Paste your destination instance's Public IP or Private IP (if Jenkins is in the same VPC)
  - Username: jenkins
  - Remote Directory: Enter /var/www/app (the root path where transfers begin)

- Click **Advanced...** directly under the server fields to input your connection keys:
  - Check **Use password authentication, or use a different key** if needed, or simply use the global key block.
  - In the **Key** field, select the Test server credential you created in the previous step.

- Click **Test Configuration**. Ensure it returns a green **Success** status, then click **Save**.

## Step-05: Create Jenkins Job

- Navigate to Jenkins Dashboard &rarra; Click **New Item** button.
  - **Name**: maven-app-build-deploy
  - **Type**: Freestyle
  - **General settings**
    - **Description**: Freestyle jenkins job for building and deploying Maven Application.
  - **Source Code Management**
    - _Git_
      - **Repository URL**: <your_github_repo_url>
      - **Credentials**: <select-creds-created_step_1.2>
      - **Branches to build**: main
  - **Build Triggers**
    - **GitHub hook trigger for GITScm polling**: Enable
  - **Build Steps**
    - Add Build step >> _Invoke top-level Maven targets_
      - Maven Version: maven-3.9.16
      - Goals: clean verify
  - **Post-build Actions**
    - Click **Add post-build action** &rarr; **Send build artifacts over SSH**
    - In the **SSH Server** block, choose your server profile (Test-Server) from the **Name** dropdown selection.
    - Under **Transfer Set**, accurately map the target artifacts and execution steps:
      - **Source files**: Enter `target/*.jar` (this tells Jenkins to look for the compiled JAR inside the local workspace).
      - **Remove prefix**: Enter `target/` (this prevents Jenkins from re-creating an empty target sub-folder structure on your remote EC2 environment).
      - **Remote directory**: Enter /var/www/app (the exact location on the remote instance where your application file will deploy).
      - **Exec command**: Paste the deployment lifecycle handling script into this block to safely stop old runtimes and execute your newly uploaded code:

        ```
        # Force the system service to restart and load the newly transferred file
        systemctl restart my-java-app.service

        # Verify the service is successfully up and running
        systemctl is-active my-java-app.service

        echo "Deployment complete over SSH!"
        ```

## Step-06: Run Jenkins Job

- In order to trigger the Jenkins Job, check-in all the changes from your local system to the GitHub repo (on main branch).

## Step-07: Verify the results

- Select the Jenkins Job
- Check the status of latest _build#_ under the "Build History" box on the bottom left.
- For more details, select the **Build** &rarr; **Console output**.
- To access the application, connect to the test server over the SSH and switch to /var/www/app directory and run the following command:

```
# To see the deployed App .jar file
ls -l

# To run the application
java -jar app.jar

# You should see a "Hello World!" message
```
