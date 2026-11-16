# Hands-on Lab: Create an automated Jenkins based CI Pipeline for building and Unit Testing Maven App

`[Developer Commit] ──> [GitHub]──> [Jenkins Pipeline] ──> [Build Maven App] ──> [Unit Test Maven App]`

## Prerequisites

- Jenkins Server with the following tools configured:
  - java 21
  - maven
  - git
- GitHub Account
- GitHub Repository with a Maven Application (Java 21)

## Install Jenkins Plugins

## Generate GitHub Authentication Token (PAT) and Save it on Jenkins

## Create a Jenkinsfile

```groovy
pipeline {
    agent any

    tools {
        maven 'maven-3.9.16'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Fetching the latest project source code...'
                checkout scm
            }
        }

        stage('Compile') {
            steps {
                echo 'Compiling application source code...'
                // Compiles application source code without running tests yet
                sh 'mvn clean compile'
            }
        }

        stage('Unit Test') {
            steps {
                echo 'Executing JUnit unit tests...'
                // Runs unit tests and generates code coverage execution reports
                sh 'mvn test'
            }
            post {
                always {
                    // Automatically parses and displays test results inside the Jenkins UI
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
    }

    post {
        success {
            echo 'CI Pipeline completed successfully! Code is compiled and all unit tests passed.'
        }
        failure {
            echo 'CI Pipeline execution failed. Please check build console logs or test failure reports.'
        }
    }
}
```

## Create a Jenkins Job (Pipeline)

## Push the changes to SCM (GitHub) to trigger the Pipeline

## Verify the results | Unit Test results | Maven Build
