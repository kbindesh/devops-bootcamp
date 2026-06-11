# Hands-on Lab: Create a Jenkins based CI Pipeline for Maven Application

## Prerequisites

- Jenkins Server
- GitHub Account
- GitHub Repository with a Maven Application (Java 21)

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
