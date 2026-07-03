# AWS CLI Reference

## 01. Install and Configure AWS CLI

### 1.1 Install AWS CLI

Kindly refer this official documentation link for downloading and installing AWS CLI tool: </br>
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

- In order to make sure that the installation was successful, kindly launch _terminal/command prompt/powershell_ prompt and run the following command:

```bash
# After installing AWS CLI, check it's version
aws --version

# Preceding command should return install version of AWS CLI
```

### 1.2 Create an IAM User for AWS CLI Authentication and generate Access keys

- Navigate to AWS Management Console &rarr; IAM &rarr; Users &rarr; Create User
  - **Name**: awscliuser
  - **Provide user access to the AWS Management Console**: Disable
  - **Attach policies directly**: AdministratorAccess

- Now, open the user (e.g. awscliuser) detail page &rarr; Security credentials &rarr; Access keys &rarr; Create access key
  - Download the generated keys in .csv format

### 1.3 Configure Access keys on local system for AWS CLI

- Switch to your local system &rarr; launch _terminal/command prompt/powershell_ and run the following commands to configure the credentials for AWS CLI:

```bash
# Connect to your AWS Account using AWS CLI
aws configure

# Enter Access Key, Secret Access Key, Region and Output format (text/json) when prompted

# To check if authentication is working, try querying something from your account using AWS CLI
aws iam list-users

# The preceding command should return user lists from your AWS account
```

## 02. AWS CLI Command Reference

- Official Documentation - https://docs.aws.amazon.com/cli/latest/

### 2.1 AWS CLI Command Syntax

- The basic syntax for any AWS CLI command follows the pattern:

```bash
# Syntax
aws <service> <operation> [options]

# Examples
aws iam list-users
aws s3 ls
```

- You use it to interact with cloud resources directly from your terminal rather than clicking through the web console.

### 2.2 Configuration & Setup Commands

```bash
# To configure AWS CLI credentials
aws configure

# To verify AWS CLI configuration
aws sts get-caller-identity

# Check AWS CLI installation
aws --version
```

### 2.3 Universal AWS CLI Utility Help

```bash
# Get inline help
aws s3 help

aws iam list-users help

aws ec2 describe-instances help
```

### 2.4 Amazon S3 (Simple Storage Service) Commands

```bash
# Displays all S3 buckets in your account
aws s3 ls

# Create a new S3 bucket
aws s3 mb s3://my-new-bucket-name

# Upload a file from your system to a target bucket
aws s3 cp localfile.txt s3://my-new-bucket-name/

# Delete an empty bucket
aws s3 rb s3://my-new-bucket-name/
```

### 2.5 Identity and Access Management (IAM) Commands

```bash
# List active users
aws iam list-users

# Create an IAM user
aws iam create-user --user-name $USER_NAME
```
