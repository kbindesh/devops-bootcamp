#!/bin/bash
yum install -y java-21-amazon-corretto-devel
java --version
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum -y upgrade
yum install -y jenkins
systemctl start jenkins
systemctl enable jenkins