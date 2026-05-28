# Jenkins CI Pipeline with SonarQube integration

In this lab, you will setup a Jenkins based Continuous Integration (CD) pipeline with automated SonarQube static code analysis.

## Prerequisites

- A _Jenkins_ server with admin privileges and with following tools configured:
  - git
  - java (21+)
  - maven
- A _GitHub_ account
- A _Github repository_ (private) with a Maven Project and a Webhook to Jenkins Server.

## Step-01: Setup SonarQube Cloud Account

- Navigate to https://www.sonarsource.com/products/sonarqube/cloud/ >> click on **Try now** button >> GitHub
- If prompted, enter your **GitHub credentials** to sign-in.

## Step-02: Generate a SonarQube Authentication token

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

## Step-04: Install SonarScanner Jenkins Plugin

- Jenkins Dashboard >> **Manage Jenkins** >> **Plugins**
- Select Available plugins tab >> serach for **SonarQube scanner** >> Select and Install

## Step-05: Configure `SonarQube Server details` on Jenkins

- Jenkins Dashboard >> Manage Jenkins >> System.
  Scroll down all the way to **SonarQube server** section (thanks to _sonarqube scanner_ plugin).
- Click on **Add SonarQube** button
  - **Name**: sonarqube-server
  - **Server URL**: https://sonarcloud.io
  - **Server Authentication Token**: <select_sonar_token_we_created_earlier>
- Click **Save** button

## Step-06: Install `SonarQube Scanner` on Jenkins server manually and save it's location on Jenkins

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

- **Save the Location in Jenkins**
  - Navigate to Manage Jenkins > Tools.

  - Scroll down to the SonarQube Scanner section and click **Add SonarQube Scanner**.
    - **Name**: sonar-scanner
    - **Install automatically**: Uncheck this box.
    - **SONAR_RUNNER_HOME**: /opt/sonar-scanner (enter exact absolute path where you installed it)

## Step-07: Create SonarQube Organization & Project

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

## Step-08: Add Code review stage to Jenkinsfile (using SonarQube)

```groovy
pipeline {
    agent any

    tools {
        // Names must exactly match your 'Manage Jenkins' -> 'Tools' definitions
        maven 'maven-3.9.15'
        jdk   'java-21'
        sonarScanner 'sonar-scanner'
    }

    stages {

        stage('Build & Test') {
            steps {
                sh 'mvn clean verify -DskipTests=false'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // 'SonarCloud' must match the Server name in Manage Jenkins -> System.
                // This block automatically injects your saved token securely behind the scenes.
                withSonarQubeEnv('sonarqube-server') {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.organization=your-sonarcloud-organization-key \
                        -Dsonar.projectKey=your-unique-project-key \
                        -Dsonar.sources=src/main/java \
                        -Dsonar.tests=src/test/java \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                    """
                }
            }
        }

        stage('Quality Gate') {
            options {
                timeout(time: 2, unit: 'MINUTES')
            }
            steps {
                script {
                    // Requires setting up a Webhook in SonarCloud pointing to your Jenkins URL
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        error "Pipeline aborted due to Quality Gate failure: ${qg.status}"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```

## Step-09: Push changes to GitHub

```bash
git add .

git commit -m "Add SonarQube logic to jenkinsfile"

git push -u origin main
```

## Step-10: Create a Jenkins Job

- Navigate to Jenkins Dashboard >> **New Item**
  - Name: _mvn-build-review-ci-pipeline_
  - Job type: Pipeline
  - Description: This jenkins pipeline job is responsible for building, reviewing publishing maven(java) app.
  - Pipeline script from Git SCM
  - Repository URL: <your_github_repo_url>
  - Credentials: select github-credential from the drop-down list
  - Branch: main

## Step-11: Trigger the Jenkins Job and Verify the code review results
