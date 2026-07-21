# Amazon Virtual Private Cloud (VPC)

## 01. VPC Overview

- An Amazon VPC (Virtual Private Cloud) is your own isolated, private logical network inside the AWS cloud.
- Think of it as a virtual data center where you have complete control over networking components like:
  - IP addresses
  - subnets
  - routing
  - security

## 02. How Amazon VPC works?

- Here is a step-by-step breakdown of how a VPC works and how its core components fit together.

### Step-01: Define the VPC and IP Range

### Step-02: Divide the VPC into Subnets

### Step-03: Connect VPC to the Internet via Internet Gateway

### Step-04: Route Traffic Using Route Tables

### Step-05: Secure the Network Layers

## 03. Summary: How Traffic Flows (visualizing Your Web Server)

1. A user types your EC2 instance's IP address into a web browser.
2. The request travels over the internet and hits the Internet Gateway.
3. The Internet Gateway checks the Public Route Table and sends the traffic to the Public Subnet.
4. The NACL evaluates the subnet traffic; if allowed, the traffic moves inside.
5. The Security Group checks port 80/443; if allowed, the request hits your Apache Web Server.
