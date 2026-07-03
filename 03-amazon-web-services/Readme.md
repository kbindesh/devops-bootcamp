# Amazon Web Services (AWS)

## 01. `Amazon Web Services (AWS)` Overview

- Amazon Web Services (AWS) is a secure, global cloud computing platform that offers over 200 fully featured services on demand.

- Instead of buying and maintaining physical data servers, users rent computing power, database capacity, and storage on a pay-as-you-go basis.

## 02. Key Applications of AWS

- Application Hosting
- Data Storage & Backup
- Database Management
- Big Data Analytics
- Game Development
- Serverless Computing
- Artificial Intelligence
- DevOps Automation
- IoT Applications

## 03. Cloud/AWS Service Models

Cloud service models dictate what you manage versus what the provider manages.

**1. Infrastructure as a Service (IaaS)**

- Infrastructure as a Service (IaaS) provides on-demand access to fundamental computing resources over the internet.
- Instead of buying physical hardware, you rent virtualized resources.

**2. Platform as a Service (PaaS)**

- Platform as a Service (PaaS) provides a pre-configured cloud environment that abstracts away underlying hardware, operating systems, and infrastructure management.
- Developers can focus entirely on writing application code and data management without worrying about server provisioning, patching, or scaling.

**3. Software as a Service (SaaS)**

- SaaS refers to completed, managed products where the provider manages the entire infrastructure and application.

## 04. AWS Deployment Models

The deployment models define the ownership, accessibility, and physical location of that infrastructure.

### 4.1 Cloud/AWS Deployment Models

**1. Public Cloud**

- Computing services offered by third-party providers over the public internet, making them available to anyone who wants to purchase them.
- Owned and operated entirely by the cloud provider (e.g., AWS data centres).
- Multi-tenant
- Cost Model: Pay-as-you-go (OpEx)
- Examples: AWS, Microsoft Azure, GCP, OCI

**2. Private Cloud (On-Premises)**

- Computing services dedicated solely to a single organization, offering highly isolated environments.
- Can reside physically at your company’s on-site data centre or be hosted by a third-party vendor.
- Single Tenant
- Cost Model: High upfront hardware cost (CapEx)
- Examples: VMware

**3. Hybrid Cloud**

- A blended environment that connects public cloud resources with private, on-premises infrastructure, allowing data and apps to be shared between them.
- Simultaneously split between a public cloud provider and your local data centre.
- Cost Model: Blended CapEx and OpEx

**4. Community Cloud**

- A shared cloud environment accessible only to a specific group of organizations that have common concerns (e.g., mission, security requirements, policy, compliance).
- Managed and hosted internally by the member organizations or by a third-party provider.
- Multi-tenant, but strictly limited to verified members of that specific community.
- Example: AWS GovCloud

## 05. Setup AWS Account (Free Tier)

- To create a new AWS Free Tier account, visit the official Sign up page (https://aws.amazon.com/free/)

- The updated AWS Free Tier gives new users $100 in upfront credits which will be valid for over a 6-month trial period.

### Prerequisites

1. Unique Email Address

2. Active Mobile Phone Number (with SMS facility)
3. Credit or Debit Cards (with International Transactions Enabled)

### Step-by-Step Account Setup

#### Step-01: Verify Email & Set Credentials

- Navigate to official sign-up page https://aws.amazon.com/free/
- Enter your root user email address and a unique AWS account name.
- Click Verify email address to receive a 6-digit verification code in your email inbox.
- Enter the code and set a strong, secure password for your root user account.

#### Step-02: Select Account Type & Contact Details

- Choose **Personal** if you are setting up this account for learning or individual practice.
- Fill out your full name, phone number, country, and residential address.
- Accept the AWS Customer Agreement to proceed

#### Step-03: Provide Identity and Billing Verification

- Enter a valid credit card, debit card, or UPI ID (available for Indian accounts).

- `Note`: AWS will issue a temporary hold of $1 USD/Rs 2 (or equivalent local currency) to verify identity, which is refunded in 3–5 days.

#### Step-04: Verify Phone Number

- Choose to receive an identity verification code via _text message (SMS)_ or _voice call_.
- Complete the security CAPTCHA, type in the received code, and click continue

#### Step-05: Select the Free Support Plan

- Select _Basic Support - Free_ to finish without enrolling in paid plans

- Click _Complete Sign Up_.
- AWS Account Activation usually processes in a few minutes, but can take up to 24 hours.

## 06. AWS Infrastructure

- Source: https://aws.amazon.com/about-aws/global-infrastructure/

- The AWS Global Infrastructure is the physical and virtual hardware network engineered by Amazon Web Services to deliver secure, highly resilient, and low-latency cloud systems.

- It functions as a structured hierarchy, dividing global computational resources into specific geographic layers.

### 6.1 The Architectural Hierarchy

**1. AWS Regions**

- Distinct, isolated physical locations grouped across global geographic zones (such as North America, Europe, or Asia Pacific).
- Every region operates independently, keeping data strictly within localized boundaries unless cross-region replication is turned on manually.
- Each AWS Region is designed to contain a minimum of three separate Availability Zones to prevent full regional system outages

**2. Availability Zones (AZs)**

- Physically separate, logical data center clusters residing within a single designated AWS Region.
- Equipped with completely independent power grids, cooling infrastructure, physical security, and specialized generator backups
- Connected via high-throughput, redundant, ultra-low-latency fiber optic networking pipelines.

**3. Points of Presence (PoP)**

- A sprawling edge network containing hundreds of specialized Edge Locations and Regional Edge Caches.
- Handles content delivery via Amazon CloudFront (CDN) and resolves network addresses via Amazon Route 53 (DNS).

## 07. AWS Key Service Categories

- **IAM**
  - Identity and Access Management (IAM)
- **Compute**
  - **Amazon EC2**
    - Virtual Servers (IaaS)
  - **AWS Lambda**
    - Code runs only on demand, event-driven
  - AWS Elastic Beanstalk
    - Code deployment, auto-managed

- **Network**
  - **AWS Virual Private Cloud (VPC)**

  - **Amazon Elastic Load Balancer (ELB)**
  - **NAT Gateway**
  - **Internet Gateway**
  - Amazon Route53
  - Amazon CloudFront

- **Storage**
  - **Amazon S3** (object storage)
    - Files, media, backups, static websites
  - **Amazon EBS** (block storage)
    - OS drives, databases, EC2 instances
  - **Amazon EFS** (file storage)
    - Shared directories across multiple servers

- **Containers**
  - Amazon ECS
    - AWS-native container orchestration service
  - **Amazon EKS**
    - Managed Kubernetes service
  - **Amazon ECR**
    - Container image registry used to store and manage Docker images.
