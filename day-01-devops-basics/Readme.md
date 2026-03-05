# DevOps Basics

In this section, you will learn the following concepts:

- SLDC Process
- DevOps
- Continous Integration (CI) process
- Continuous Deliver (CD) process

## 01. Software Development Lifecycle (SDLC) Process

### SDLC Overview

- The software development lifecycle (SDLC) is the cost-effective and time-efficient process that development teams use to design and build high-quality softwares.
- The goal of SDLC is to minimize project risks through forward planning so that software meets customer expectations during production and beyond.

### How does the SDLC work?

- The SDLC outlines several tasks required to build a software application.
- The development process goes through several stages as developers add new features and fix bugs in the software.
- Some common SDLC phases are as below:
  - **Plan**: The planning phase typically includes tasks like cost-benefit analysis, scheduling, resource estimation, and allocation.
  - **Design**: In the design phase, software engineers analyze requirements and identify the best solutions to create the software.
  - **Implement**: In this stage, the development team codes the product. They analyze the requirements to identify smaller coding tasks they can do daily to achieve the final result.
  - **Test**: The development team combines automation and manual testing to check the software for any bugs.
  - **Deploy**: The deployment phase includes several tasks to move the latest build copy to the production environment, such as packaging, environment configuration, and installation.

### What are various SDLC models?

- Waterfall
- Iterative
- Spiral
- Agile

### Which technologies/tools can help you with your SDLC requirements?

- Github
- BitBucket
- Jenkins
- SonarQube/SonarCloud
- Maven
- Sonatype Nexus
- Travis CI
- Circle CI
- JFrog
- AWS CodeBuild
- AWS CodePipeline
- AWS CodeGuru
- Azure Pipelines
- Azure Repos
- Grafana
- Prometheus

### Why we need SDLC automation?

- In order to test and deploy software versions at faster rates, more frequently and reliably.
- To be able to deploy frequently, we should have standard, tested and repeatable deployment processes and those processes should not always depend on people.
- **CI** and **CD** aims to introduce automation to the deployment process, which basically allows us to release new software versions frequently and reliably.

## 02. Introduction to `DevOps`

### What is `DevOps`?

- _DevOps_ is a set of cultural practices that allows people, processes, and tools to build and release software faster, more frequently, and more reliably.
- DevOps is a set of practices, tools, and a cultural philosophy that automate and integrate the processes between software development (Dev) and IT (Ops) teams.
- It emphasizes team empowerment, cross-team communication and collaboration, and technology automation.
- The term DevOps, a combination of the word development and operations, reflects the process of integrating these disciplines into a continuous process.

### Advantages of `DevOps`

- Better product delivery
- Faster time to Production
- Faster issue resolution
- Reduced complexity
- Greater scalability
- More stable operating environments
- Better resource utilization

### Commonly used `DevOps Tools`

- Planning & Collaboration
  - Jira
  - Slack
  - Trello
  - Azure Boards

- Version Control systems
  - Git
  - GitHub
  - GitLab
  - Bitbucket

- Continous Integration and Continuous Delivery
  - Jenkins
  - GitHub Actions
  - GitLab
  - Circle CI
  - Travis

- Containerization & Orchestration
  - Docker
  - Kubernetes

- Configuration Management and Infrastructure-as-Code (IaC)
  - Ansible
  - Chef
  - Terraform

- Monitoring & Observability
  - Prometheus
  - Grafana

## 03. Continuous Integration (CI) and Continuous Delivery (CD)

### Continous Intrgation (CI) Overview

- Continuous integration is a DevOps software development practice where developers regularly merge their code changes into a central repository, after which automated builds and tests are run.
- Continuous integration most often refers to the build or integration stage of the software release process and entails both an automation component (e.g. a CI or build service) and a cultural component (e.g. learning to integrate frequently).
- The key goals of continuous integration are to find and address bugs quicker, improve software quality, and reduce the time it takes to validate and release new software updates.

#### Why is Continuous Integration needed?

- In the past, developers on a team might work in isolation for an extended period of time and only merge their changes to the master branch once their work was completed.
- This made merging code changes difficult and time-consuming, and also resulted in bugs accumulating for a long time without correction.
- These factors made it harder to deliver updates to customers quickly.

#### How does Continuous Integration work?

- With _Continuous Integration_, developers frequently commit to a shared repository using a version control system such as Git.
- Prior to each commit, developers may choose to run local unit tests on their code as an extra verification layer before integrating.
- A continuous integration service automatically builds and runs unit tests on the new code changes to immediately surface any errors.

#### Continuous Integration Benefits

- Improve Developer Productivity
- Find and Address Bugs Quicker
- Deliver Updates Faster

#### Pillars of Continuous Integration

- Source control management
- Automated testing
- Build automation
- Code review automation

#### Commonly used Continuous Integration(CI) Tools

- Jenkins
- AWS CodePipeline
- Bitbucket Pipelines
- Circle CI
- Azure Pipelines
- GitLab
- Atlassian Bamboo
- Travis CI

### What is Continous Delivery (CD)?

- With _Continuous Delivery_, code changes are automatically built, tested, and prepared for a release to production.
- CD focuses an organization on building a streamlined, automated software release process.
- CD expands upon continuous integration by deploying all code changes to a testing environment and/or a production environment after the build stage.
