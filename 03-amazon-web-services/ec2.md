# Amazon Elastic Compute Cloud (EC2)

## 01. EC2 Overview

- Amazon Elastic Compute Cloud (EC2) provides secure, scalable, and on-demand virtual servers in the AWS cloud.
- It eliminates the need to buy physical hardware upfront, allowing you to quickly rent compute capacity and scale it up or down to match your exact business needs.

## 02. Amazon EC2 Core Concepts

- To successfully spin up and manage an EC2 instance, you need to understand several key components:
  - Amazon EC2 Instance Types
  - ⁠Amazon Machine Images (AMIs)
  - Security Groups
  - Key Pairs
  - Storage - Amazon Elastic Block Store (EBS) volumes
  - User Data Scripts

## 03. Amazon EC2 - Pricing Models

EC2 offers flexibility in how you pay for your compute resources:

- On-Demand
  - You pay for compute capacity by the second or hour with no long-term commitments.

- Reserved Instances
  - You reserve capacity for a 1- or 3-year term, receiving a significant discount compared to On-Demand pricing

- Spot Instances
  - You can bid on unused EC2 capacity at deeply discounted rates.
  - These are ideal for highly fault-tolerant workloads, but AWS can interrupt them with a two-minute warning.

## 04. Lab: Create and Connect to Windows EC2 Instance

### Step-4.1: Create an EC2 Instance with Windows AMI

- Log into the AWS Management Console.
- Type **EC2** in the top search bar and select **EC2**.
- Click the **Launch instance** button.
- Name your server under **Name** and **tags** (e.g., My-Windows-Server).

- Step-XX: Choose **Windows** under Application and OS Images (Amazon Machine Image) &rarr; Microsoft Windows Server 2022 Base
- **Instance type**: t2.micro (or t3.micro depending on your region) under Instance type.

- Click Create new key pair under Key pair (login).
  - Name your key
  - Encryption Algorithm: RSA
  - Format: .pem

- Click **Create key pair** and save the downloaded file securely.
- Check **Allow RDP traffic** from under _Network settings_.
- Change the dropdown from _Anywhere_ to _My IP_ for maximum security.
- Leave storage at the default 30 GB settings &rarr; **Launch instance**
- Click **View all instances** and wait until the instance state shows Running.

### Step-4.2: Get the Windows Administrator Password

- Select your running Windows instance by checking the box next to it.
- Click the **Connect** button at the top of the console page.
- Switch to the RDP client tab.
  - Note down the **Public DNS** and the **User name** (usually Administrator).
  - Click **Get password**.
  - Click **Upload private key file** and select the .pem file you downloaded in the previous step.
  - Click **Decrypt password** &rarr; Copy the decrypted password to your clipboard.

### Step-4.3: Connect to a Windows EC2 Instance via Remote Desktop Protocol (RDP)

- Open the **Remote Desktop Connection** app on your local computer &rarr; paste the Public DNS into the Computer field and click **Connect**.
  - **Username**: Enter **Administrator** when prompted for credentials.
  - **Password**: Paste the decrypted Password you copied earlier.

- Click **OK** and accept any security certificates to open the Windows desktop.

## 05. Lab: Create and Connect to a Linux EC2 Instance

### Step-5.1: Create an EC2 Instance with Linux AMI

- Log into your AWS Management Console.
- Open the **EC2** Dashboard &rarr; Click **Launch instance** button.

- Name your instance under Name and tags: LINUX-WEB-SERVER
- Amazon Machine Image (AMI): Amazon Linux 2023 6.1 kernel
- Instance Type: t2.micro (or other)
- Key Pair: Click **Create new key pair**
  - Name your key, set the type to **RSA**, and choose **.pem** format.
- Under **Network settings** section
  - Allow SSH traffic: Enable checkbox
  - Traffic rules: My IP to restrict command-line entry to your network.
- Under **Configure storage** section
  - Volume type: gp2
  - Capacity: 10GB

- Click the **Launch instance** button in the right-side summary window.

### Step-5.2: Connect to a remote Linux EC2 Instance via SSH (Secure Shell)

- Before running the connection command, ensure you have the following pieces of information from your AWS Management Console:
  - The Private Key File (.pem)
  - Public IPv4 Address
  - Security Group Rule: Should allow inbound SSH traffic on port 22.
  - AMI Default Username:
    - Amazon Linux 2 / Amazon Linux 2023: ec2-user
    - Ubuntu: ubuntu
    - CentOS: centos
    - RHEL: ec2-user or root
    - Debian: admin

- Open your local machine's terminal (or Git Bash / Command Prompt/ Powershell) and navigate to the directory holding your _.pem_ key.

```bash
# Navigate to the directory where your .pem key file is saved
cd /path/to/your/key-folder

# Restrict key permissions
chmod 400 your-key-pair-name.pem

# Run the SSH command
ssh -i "your-key-pair-name.pem" username@your-instance-public-ip
ssh -i "my-aws-key.pem" ec2-user@44.211.43.19

# Accept the Host Fingerprint | type "yes"
```

> [!NOTE]
> If Windows flags a "permissions are too open" error, right-click the .pem file → Properties → Security → Advanced → Disable Inheritance, and remove all users except your specific Windows account

### Step-5.3: Configure a Linux EC2 Instance as a _Web Server_ using _Apache Web Server_

#### 5.3.1: Configure the AWS Security Group

- Your instance must be allowed to receive web traffic before you can view your site:

- Select your EC2 Instance &rarr; **Security** tab &rarr; Click the Security group name link &rarr; Inbound Rules &rarr; Add these two specific rules:
  - HTTP | Port 80 | Source: Anywhere-IPv4 (0.0.0.0/0)
  - HTTPS | Port 443 | Source: Anywhere-IPv4 (0.0.0.0/0)

#### 5.3.2: Update Packages and Install Apache HTTP Server

- Connect to your AL2023 instance via SSH and run the following commands to update the system repository and install the Apache HTTP server package (httpd):

```bash
# Update all existing system packages
sudo dnf update -y

# Install the Apache Web Server
sudo dnf install httpd -y

# Start the Apache service immediately
sudo systemctl start httpd

# Enable Apache to run automatically on system boot
sudo systemctl enable httpd

# Verify that the service is active and running
sudo systemctl status httpd
```

#### 5.3.3: Configure Web Directory Permissions

```bash
# Add the ec2-user to the "Apache" deployment group | By default, root user owns the web root directory /var/www/html
sudo usermod -a -G apache ec2-user

# Log out and log back in to refresh group memberships
exit

# Reconnect to your instance via SSH, then apply the correct group directory permissions

# Change group ownership of the web root to the apache group
sudo chown -R ec2-user:apache /var/www

# Modify directory permissions to allow group write access
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \+

# Modify file permissions so future files retain write access
find /var/www -type f -exec sudo chmod 0664 {} \+
```

#### 5.3.4: Create a Test Page

- Deploy a basic homepage to verify that the configurations are functional

```bash
echo "<h1>Welcome to my Sample App hosted on Amazon Linux 2023 Apache web server</h1>" > /var/www/html/index.html
```

#### 5.3.5: Verify your Apache WebServer App deployment via Web Browser

- Locate your Public IPv4 address from your AWS EC2 Dashboard.
- Open a new tab in your web browser &rarr; Enter your address using HTTP protocol: `http://your-ec2-public-ip`
- You should see your custom "Welcome to Apache" or "It Works!" text displayed on screen.
