# Sending Email Notifications through Jenkins Pipelines

- To set up robust production-grade email notifications, the industry standard is to use the **Email Extension Plugin** (emailext).
- This plugin provides much cleaner formatting, HTML support, and conditional triggers compared to the basic built-in Jenkins email tool.

## Prerequisites

- Jenkins Server
- Mailtrap Account (or any other Email Delivery Platform)

## Step 1: Add Credentials to Jenkins

- Save your SMTP keys in the Jenkins Credentials Store. Manage Jenkins &rarr; Credentials:

1. **Testing Account**: Create a Username with password block with the ID mailtrap-smtp-creds (use your Mailtrap Inbox SMTP credentials).

2. **Production Account**: Create a Username with password block with the ID aws-ses-smtp-creds (use your AWS SES SMTP credentials).

## Step 2: Complete Environment-Isolated Jenkinsfile

- Here is your complete, production-ready Jenkinsfile.
- It uses a runtime parameter (ENV_PROFILE) to determine which SMTP server configurations to bind during execution.

```groovy
pipeline {
    agent {
        label 'maven-runner'
    }

    parameters {
        // Allows developers to select the environment context from the Jenkins UI
        choice(name: 'ENV_PROFILE', choices: ['TESTING', 'PRODUCTION'], description: 'Select runtime profile to dynamically bind infrastructure and SMTP servers.')
    }

    options {
        timeout(time: 2, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '30'))
        disableConcurrentBuilds()
        skipStagesAfterUnstable()
    }

    tools {
        maven 'maven-3.9.16'
        jdk   'java-21'
    }

    environment {
        APP_NAME          = 'maven-enterprise-app'
        STAGING_SERVER    = '10.0.12.45'
        PROD_SERVER       = '10.0.14.90'
        SONAR_SERVER_NAME = 'SonarQubeServer'

        // Non-mail secure credentials
        SONAR_TOKEN       = credentials('sonar-server-token')
        SSH_DEPLOY_KEY    = credentials('ssh-prod-deploy-key')
    }

    stages {
        /*
         * STAGE: Initialize Environment Profile
         * PURPOSE: Dynamically configures the pipeline's networking addresses based on the target profile.
         *          Binds your real cloud routing for PRODUCTION, and isolates testing inside Mailtrap.
         */
        stage('Initialize Profile') {
            steps {
                script {
                    echo "Initializing build sequence under the [ ${params.ENV_PROFILE} ] configuration profile."

                    if (params.ENV_PROFILE == 'PRODUCTION') {
                        // Production Bindings: Routing traffic out to AWS SES
                        env.SMTP_SERVER       = '://amazonaws.com'
                        env.SMTP_PORT         = '587'
                        env.SMTP_CRED_ID      = 'aws-ses-smtp-creds'
                        env.SENDER_ADDRESS    = 'jenkins-production@company.com'
                        env.NOTIFICATION_LIST = 'release-team@company.com, engineering-alerts@company.com'
                    } else {
                        // Testing Bindings: Trapping all traffic safely within the Mailtrap Sandbox
                        env.SMTP_SERVER       = 'sandbox.smtp.mailtrap.io'
                        env.SMTP_PORT         = '2525' // Alternative ports: 587 or 465
                        env.SMTP_CRED_ID      = 'mailtrap-smtp-creds'
                        env.SENDER_ADDRESS    = 'jenkins-testing@company.com'
                        env.NOTIFICATION_LIST = 'qa-engineers@company.com, build-tester@company.com'
                    }
                }
            }
        }

        stage('Compile & Unit Test') {
            steps {
                echo 'Compiling code and generating test coverage reports...'
                sh 'mvn clean test'
            }
            post {
                success {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Security & Quality Analysis') {
            parallel {
                stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv("${env.SONAR_SERVER_NAME}") {
                            sh "mvn sonar:sonar -Dsonar.projectKey=${env.APP_NAME} -Dsonar.login=${SONAR_TOKEN}"
                        }
                    }
                }
                stage('OWASP Dependency Check') {
                    steps {
                        echo 'Scanning open-source dependencies for known CVE flaws...'
                        sh 'mvn dependency-check:check'
                    }
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                echo 'Checking SonarQube Quality Gate status...'
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to SonarQube Quality Gate Failure. Status: ${qg.status}"
                        }
                    }
                }
            }
        }

        /*
         * STAGE: Package & Publish
         * SAFETY GUARD: Only runs when the production profile is selected to prevent test artifacts from hitting Nexus.
         */
        stage('Package & Publish') {
            when { expression { return params.ENV_PROFILE == 'PRODUCTION' } }
            steps {
                echo "Packaging final artifact and publishing to ${env.NEXUS_REPO_URL}"
                withCredentials([usernamePassword(credentialsId: 'nexus-deployer-account', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh "mvn deploy -DskipTests=true"
                }
            }
        }

        stage('Deploy to Staging') {
            steps {
                echo "Deploying out to Staging Node: ${env.STAGING_SERVER}"
                sh "scp -i ${SSH_DEPLOY_KEY} target/*.war ubuntu@${env.STAGING_SERVER}:/opt/tomcat/webapps/"
            }
        }

        stage('Smoke Test') {
            steps {
                echo 'Validating environment health check endpoints...'
                sh "curl --fail http://${env.STAGING_SERVER}:8080/${env.APP_NAME}/health || exit 1"
            }
        }

        stage('Gate to Production') {
            when { expression { return params.ENV_PROFILE == 'PRODUCTION' } }
            steps {
                timeout(time: 1, unit: 'DAYS') {
                    input message: "Approve deployment of version ${env.BUILD_NUMBER} directly to Production?",
                          submitter: 'release-managers-group'
                }
            }
        }

        stage('Deploy to Production') {
            when { expression { return params.ENV_PROFILE == 'PRODUCTION' } }
            steps {
                echo "Executing release pipeline on production node: ${env.PROD_SERVER}"
                sh "scp -i ${SSH_DEPLOY_KEY} target/*.war ubuntu@${env.PROD_SERVER}:/opt/tomcat/webapps/"
            }
        }
    }

    /*
     * POST ACTIONS: Handles workspace cleanups and dispatches environment-isolated alerts.
     */
    post {
        always {
            echo 'Executing workspace cleanup...'
            cleanWs()
        }

        success {
            echo "Pipeline built successfully. Dispatching email alerts..."
            // Dynamically pulls the matching SMTP user/pass profile from the Jenkins credentials store
            withCredentials([usernamePassword(credentialsId: "${env.SMTP_CRED_ID}", usernameVariable: 'SMTP_USER', passwordVariable: 'SMTP_PASS')]) {
                emailext (
                    server: "${env.SMTP_SERVER}",
                    port: "${env.SMTP_PORT}",
                    user: "${SMTP_USER}",
                    password: "${SMTP_PASS}",
                    from: "${env.SENDER_ADDRESS}",
                    replyTo: "${env.SENDER_ADDRESS}",
                    to: "${env.NOTIFICATION_LIST}",
                    subject: "SUCCESS [${params.ENV_PROFILE}]: Job '${env.JOB_NAME}' [Build #${env.BUILD_NUMBER}]",
                    body: """
                        <html>
                        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                            <h2 style="color: #2e7d32;">✔ Pipeline Succeeded Successfully</h2>
                            <hr style="border: 0; border-top: 1px solid #eee;"/>
                            <p><strong>Environment Profile Context:</strong> ${params.ENV_PROFILE}</p>
                            <p><strong>Routing Mail Server:</strong> ${env.SMTP_SERVER}</p>
                            <p><strong>Project Target:</strong> ${env.APP_NAME}</p>
                            <p><strong>Build Number:</strong> #${env.BUILD_NUMBER}</p>
                            <br/>
                            <a href="${env.BUILD_URL}" style="background-color: #2e7d32; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; display: inline-block;">View Jenkins Build Details</a>
                        </body>
                        </html>
                    """
                )
            }
        }

        failure {
            echo "Pipeline execution failed. Dispatching error logs..."
            withCredentials([usernamePassword(credentialsId: "${env.SMTP_CRED_ID}", usernameVariable: 'SMTP_USER', passwordVariable: 'SMTP_PASS')]) {
                emailext (
                    server: "${env.SMTP_SERVER}",
                    port: "${env.SMTP_PORT}",
                    user: "${SMTP_USER}",
                    password: "${SMTP_PASS}",
                    from: "${env.SENDER_ADDRESS}",
                    replyTo: "${env.SENDER_ADDRESS}",
                    to: "${env.NOTIFICATION_LIST}",
                    subject: "FAILURE [${params.ENV_PROFILE}]: Job '${env.JOB_NAME}' [Build #${env.BUILD_NUMBER}]",
                    body: """
                        <html>
                        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                            <h2 style="color: #c62828;">✘ Pipeline Execution Failed</h2>
                            <hr style="border: 0; border-top: 1px solid #eee;"/>
                            <p><strong>Environment Profile Context:</strong> ${params.ENV_PROFILE}</p>
                            <p><strong>Routing Mail Server:</strong> ${env.SMTP_SERVER}</p>
                            <p><strong>Project Target:</strong> ${env.APP_NAME}</p>
                            <p><strong>Build Number:</strong> #${env.BUILD_NUMBER}</p>
                            <p style="color: #c62828; font-weight: bold;">Review action required: Please immediately evaluate console traces to isolate errors.</p>
                            <br/>
                            """)
                    }
              }
      }
}
```
