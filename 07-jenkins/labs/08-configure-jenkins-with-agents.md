# Distributed Builds using Jenkins (Master-Slave architecture)

## Prerequisites

- AWS Account (with _EC2 Full Access_)
- Jenkins Server
- GitHub Account
- GitHub Repository with Maven project</br>

## Step-01: Setup Jenkins Server (master node)

### Step-1.1: Create an EC2 Instance and Configure as Jenkins server

- [Setup Jenkins Server](4-setting-up-jenkins-server-on-ec2.md)

### Step-1.2: Install Jenkins Plugins

- Navigate to Jenkins dashboard >> **Manage Jenkins** >> **Plugins** >> **Available Plugins**
- Search and Install following plugins:
  - _Maven Integration_
  - _Maven Invoker_
  - _GitHub_

## Step-02: Create & Configure Jenkins Agent (Maven Build Server | Node)

### Step-2.1: Create an Amazon EC2 Instance (VM)

- Sign-in to AWS Account (https://console.aws.amazon.com/).
- Navigate to EC2 service >> _Launch Instance_.
  - **Name**: Maven-Build-Server
  - **AMI**: Amazon Linux 2023
  - **Instance Type**: t2.micro
  - **Key Pair**: <your_existing_keypair>
  - **VPC/Subnet**: Default
  - **Elastic IP**: Enable
  - **Security Group**: <create_new_sg>
    - **Ingress**: Allow Ingress - SSH (22) from Jenkins Master node IP
  - **Storage**: 15 GB, GP2 (minimum for this lab)
- Click on **Launch Instance** button

### Step-2.2: Install and Configure `Java`

- Official link for java download: https://www.oracle.com/in/java/technologies/downloads/

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

### Step-2.3: Install and Configure `Maven`

- Apache maven official download page: https://maven.apache.org/download.cgi

- Now, download and configure Apache Maven

```
# Move to /opt directory
cd /opt

# Download the maven binary
wget https://dlcdn.apache.org/maven/maven-3/3.9.16/binaries/apache-maven-3.9.16-bin.tar.gz

# Unzip the downloaded maven tarball
tar -xvf apache-maven-3.9.16-bin.tar.gz

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

### Step-2.4: Install `Git`

```
# Install Git
sudo dnf install -y git

# Verify Git installation
git --version
```

## Step-03: Add Maven server as an Agent on Jenkins server

### Step-3.1: Create a new user on Maven build server for Jenkins communication

- Connect to your Maven server (ec2 instance) over SSH.

```
# Switch to sudo user
sudo su -

# List all the existing users
cat /etc/passwd

# Create a new user
useradd jenkins

# Set the password for jenkins user
passwd jenkins

# Add the jenkins user to the sudoers file
visudo

[Press "G" to go to the end of the file and press "i" to go in insert mode]

## Allow root to run any command anywhere
root    ALL=(ALL)     ALL
jenkins ALL=(ALL)     NOPASSWD: ALL
```

- **Enable password based authentication**

```
vi /etc/ssh/sshd_config

[Search for PasswordAuthentication]

# Uncomment the line
PasswordAuthentication yes

# Refresh sshd service
service sshd reload
```

### Step-3.2: Add `Maven server` as new node on `Jenkins server`

- Open Jenkins server's Dashboard >> **Manage Jenkins** >> **Manage Nodes and Cloud** >> **New Node**
- **Node Name**: maven-build-server
- **Permanent Agent**: Enable
- **# of executors**: 2
- **Remote Root Directory**: /home/jenkins
- **Launch Method**: Launch Agent via SSH
  - Host: <private_ip_of_the_maven_server>
  - **Credentials** >> Add
    - Username: jenkins
    - Password: <your_jenkins_user_passwd>
    - ID: jenkins
  - Select the created credentials from the dropdown list.
- **Host key verification strategy**: Non verifying verification strategy

### Step-3.3: Verify the connection with Maven build agent

- Jenkins Dashboard >> **Manage Jenkins** >> **Nodes** >> maven-build-server
- You should see agent added without a warning sign. Also check it in the logs.

## Step-04: Configure Maven and Java installation path on Jenkins master

- Navigate to Jenkins server dashboard >> Manage Jenkins >> Tools

- **JDK**
  - Name: java-21
  - JAVA_HOME: /usr/lib/jvm/java-21-amazon-corretto

- **Maven** - location of maven installation on Maven Agent machine (not on Jenkins master node)
  - Name: maven-3.9.16
  - MAVEN_HOME: /opt/apache-maven-3.9.16

## Step-05: Create Jenkins Job to execute it on Agent node

- Create a new Jenkins job
  - **Name**: master-slave-demo
  - **Type**: Freestyle
  - **General settings**
    - **Restrict where this project can be run**: Enable
    - **Label Expression**: `maven-build-server`
  - **Source Code Management**
    - _Git_
      - **Repository URL**: <your_github_repo_url>
      - **Credentials**: <select_creds_if_private_repo>
      - **Branches to build**: <branch_of_github_repo>
  - **Build Triggers**
    - **GitHub hook trigger for GITScm polling**: Enable
  - **Build Steps**
    - Add Build step >> _Invoke top-level Maven targets_
      - Maven Version: maven-3.9.16
      - Goals: clean verify

## Step-06: Run the Job and Verify the Job execution on Agent node

- First, verify the Job build status &rarr; Console output

- Next, take SSH to Agent machine &rarr; Switch to `/home/jenkins` directory:

```bash
cd /home/jenkins/workspace/$JENKINS_JOB_NAME/

# Inside /home/jenkins/workspace/master-slave-demo directory, you will find app code

# Inside /home/jenkins/workspace/master-slave-demo/target, you will find build artifact (.jar)
```
