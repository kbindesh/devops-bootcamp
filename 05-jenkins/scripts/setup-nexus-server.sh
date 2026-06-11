#!/bin/bash
dnf install -y java-21-amazon-corretto-devel
cd /opt
wget https://download.sonatype.com/nexus/3/nexus-3.93.0-06-linux-x86_64.tar.gz
tar -xvf nexus-3.93.0-06-linux-x86_64.tar.gz
mv nexus-3.93.0-06 nexus
useradd nexus
chown -R nexus:nexus /opt/nexus
chown -R nexus:nexus /opt/sonatype-work