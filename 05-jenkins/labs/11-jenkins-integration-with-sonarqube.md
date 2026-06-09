# Integrating SonarQube with Jenkins for Static Code Analysis

## Prerequisites

- Jenkins server with the following tools configured:
  - Git
  - Java (jdk 21 or above)
  - Maven
- GitHub Account
- GitHub Repository with a Maven App source code

## Step-XX: Setting-up SonarQube Cloud Server

### Setup SonarQube Cloud Account

- Navigate to https://www.sonarsource.com/products/sonarqube/cloud/ >> click on **Try now** button >> GitHub
- If prompted, enter your **GitHub credentials** to sign-in.

### Create SonarQube Organization & Project

- Sign-in to SonarQube Cloud account >> Click on "+" button (top-right corner) >> Select **Create new organization** --> Click on You can **create one manually** link.

- **Organization details**
  - **Name**: bindesh-dev
  - **Key**: bindesh-dev
  - **Organization Plan**: Select free

- Click on **Create Organization** button

- You will land-up on **Projects** tab. Click on **Analyze a new project** button.
- **Project Details**
  - Organization: bindesh-dev
  - Display Name: mvn-project
  - Project Key: <leave_it_to_default>
  - Project visibility: Private

## Generate a SonarQube Cloud Authentication token

- Sign-in to your SonarCloud account >> Click on your user drop-down list (top-right corner) >> **My Account**
- Select **Security** tab
  - **Generate Tokens**
    - Token Name: token-for-jenkins
    - Click on **Generate Token** button.
  - Copy the generated token and store at safe place as we'll need it in our next step.

## Save SonarQube authentication token on Jenkins server

- Navigate to Jenkins Dashboard >> Manage Jenkins >> Credentials >> System >> Global credentials (unrestricted)
- Click on New Credentials button
  - Kind: Secret Text
  - Scope: Global
  - Secret: <paste_the_sonarqube_token_generated_in_last_step>
  - ID: sonarqube-auth-token
- Click on **Create** button

## Configure Jenkins Server for SonarQube integration

### Install Jenkins Plugin

- Jenkins Dashboard >> **Manage Jenkins** >> **Plugins**
- Select Available plugins tab >> serach for **SonarQube scanner** >> Select and Install

### Save `SonarQube Server details` on Jenkins

- Jenkins Dashboard >> Manage Jenkins >> System.
  Scroll down all the way to **SonarQube server** section (thanks to _sonarqube scanner_ plugin).
- Click on **Add SonarQube** button
  - **Name**: sonarqube-server
  - **Server URL**: https://sonarcloud.io
  - **Server Authentication Token**: <select_sonar_token_we_created_earlier>
- Click **Save** button

### Install `SonarQube Scanner` on Jenkins server manually and save it's location on Jenkins

- **Install SonarQube Scanner on the Jenkins Server**
  - Official Download Page: https://docs.sonarsource.com/sonarqube-server/10.8/analyzing-source-code/scanners/sonarscanner

  - SSH into your Jenkins server and execute the following commands as root or a user with sudo privileges:

  ```bash
  # Navigate to an installation directory
  cd /opt

  # Download the latest SonarQube CLI Scanner
  sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-8.0.1.6346-linux-x64.zip

  # Unzip the package
  sudo unzip sonar-scanner-cli-8.0.1.6346-linux-x64.zip

  # Rename the folder for simplicity
  sudo mv sonar-scanner-8.0.1.6346-linux sonar-scanner

  # Give Jenkins user ownership permissions over the directory
  sudo chown -R jenkins:jenkins /opt/sonar-scanner
  ```

### Save the location of SonarQube Scanner on Jenkins

- Navigate to **Manage Jenkins** > **Tools**.

- Scroll down to the SonarQube Scanner section and click **Add SonarQube Scanner**.
  - **Name**: sonar-scanner
  - **Install automatically**: Uncheck this box.
  - **SONAR_RUNNER_HOME**: /opt/sonar-scanner (enter exact absolute path where you installed it)

## Update the `Jenkinsfile` and Check-in the changes to GitHub

## Create a Jenkins Pipeline (job)

## Trigger the Pipeline

## Verify the code review results in SonarQube
