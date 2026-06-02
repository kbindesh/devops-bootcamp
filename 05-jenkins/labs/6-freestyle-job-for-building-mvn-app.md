# Configure Jenkins Server for building Maven Applications

## Prerequisites

- AWS Account
- Jenkins Server
- GitHub Account
- GitHub Repo with Maven project code

## Configuring Jenkins Server for building Maven App

### Install Jenkins Plugins

- Navigate to Jenkins dashboard >> **Manage Jenkins** >> **Plugins** >> **Available Plugins**
- Search and Install following plugins:
  - _Maven Integration_
  - _Maven Invoker_
  - _GitHub_

### Generate & Save GitHub Credential (PAT) on Jenkins

- **Generate GitHub Personal Access Token (PAT) for Jenkins**

- **Save the GitHub PAT on Jenkins**

### Install and Configure Java

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

### Install and Configure `Maven`

- Apache maven official download page: https://maven.apache.org/download.cgi

- Download and configure Apache Maven:

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

### Configure `Maven` and `Java` installation path on Jenkins master

- Navigate to Jenkins server dashboard >> Manage Jenkins >> Tools

- **JDK**
  - Name: java-21
  - JAVA_HOME: /usr/lib/jvm/java-21-amazon-corretto

- **Maven** - location of maven installation on Maven Agent machine (not on Jenkins master node)
  - Name: maven-3.9.16
  - MAVEN_HOME: /opt/apache-maven-3.9.16

### Install `Git`

```bash
sudo dnf install -y git
```

## Create Jenkins Job

- Navigate to Jenkins Dashboard &rarra; Click **New Item** button.
  - **Name**: master-slave-demo
  - **Type**: Freestyle
  - **General settings**
    - **Description**: Freestyle jenkins job for building and deploying Maven Application.
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

## Run Jenkins Job

## Verify the results
