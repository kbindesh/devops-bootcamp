# Hands-on Lab: Integrating SonarQube with Jenkins for Static Code Analysis

- This project establishes an automated Continuous Inspection workflow by integrating SonarQube into a Jenkins CI pipeline.
- It automatically triggers static code analysis on every code commit to identify the following early in the development lifecycle:
  - bugs
  - vulnerabilities
  - code smells

`[Developer Commit] ──> [Jenkins Pipeline] ──> [SonarQube Scanner] ──> [Quality Gate Pass/Fail]`

## Prerequisites

- Jenkins server with the following tools configured:
  - Git
  - Java (jdk 21 or above)
  - Maven
- GitHub Account
- GitHub Repository with a Maven App source code

## Step-01: Setting-up SonarQube Cloud Server

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

## Step-02: Generate a SonarQube Cloud Authentication token

- Sign-in to your SonarCloud account >> Click on your user drop-down list (top-right corner) >> **My Account**
- Select **Security** tab
  - **Generate Tokens**
    - Token Name: token-for-jenkins
    - Click on **Generate Token** button.
  - Copy the generated token and store at safe place as we'll need it in our next step.

## Step-03: Save SonarQube authentication token on Jenkins server

- Navigate to Jenkins Dashboard >> Manage Jenkins >> Credentials >> System >> Global credentials (unrestricted)
- Click on New Credentials button
  - Kind: Secret Text
  - Scope: Global
  - Secret: <paste_the_sonarqube_token_generated_in_last_step>
  - ID: sonarqube-auth-token
- Click on **Create** button

## Step-04: Configure Jenkins Server for SonarQube integration

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

## Step-05: Update the `Jenkinsfile` and Check-in the changes to GitHub

- Update the Jenkinsfile by adding a dedicated stage for code review using SonarQube:

```groovy
pipeline {
   agent any

   tools {
      maven 'maven-3.9.16'
   }

   stages {
    stage('Verify Maven Application') {
      steps {
        sh 'mvn clean verify'
      }
    }

    stage ('Code Review with SonarQube') {
      steps {
        withSonarQubeEnv('sonarqube-server') {
          sh """
            mvn sonar:sonar \
              -Dsonar.organization=bindesh-dev \
              -Dsonar.projectKey=bindesh-dev_mvn-project
          """
        }
      }
    }
   }
   post {
        success {
            echo 'CI Pipeline completed successfully! Code is tested, reviewed, and packaged.'
        }
        failure {
            echo 'CI Pipeline execution failed. Please check build console logs or SonarQube quality gate results.'
        }
    }
}
```

## Step-06: Create a Jenkins Pipeline (job)

- Open your Jenkins dashboard &rarr; **New Item**.
  - **Name**: `maven-sonarqube-pipeline`
  - **Job type**: Pipeline
  - **Definition**: Pipeline script from SCM
    - **SCM**: Git
    - **Repository URL**: Enter your GitHub repo link (e.g., https://github.com)
    - **Credentials**: If your repository is private, select your GitHub access credentials from the dropdown list.
    - **Branches to build**: main
    - **Script Path**: Verify this is set to Jenkinsfile
- Click **Save**

## Step-07: Trigger the Pipeline

- Select the above created Jenkins job and click **Build now** button.

- Jenkins will first download your Jenkinsfile from GitHub, parse the execution steps, check out your complete project files into the workspace, and run the Maven build to review straight to SonarQube.

## Step-08: Verify the code review results in SonarQube

- Navigate to your SonarQube Cloud Account &rarr; Review the results.
