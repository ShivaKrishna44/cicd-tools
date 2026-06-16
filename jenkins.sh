#!/bin/bash
set -e

# Extend partition
growpart /dev/nvme0n1 4

# Extend LVs
lvextend -L +10G /dev/RootVG/rootVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

# Grow filesystems
xfs_growfs /
xfs_growfs /var
xfs_growfs /var/tmp

# Jenkins repository
curl -fsSL -o /etc/yum.repos.d/jenkins.repo 
https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Refresh repositories
dnf clean all
dnf makecache

# Install Java 21 (Required for latest Jenkins)
dnf install -y java-21-openjdk java-21-openjdk-devel fontconfig

# Set Java 21 as default
alternatives --set java /usr/lib/jvm/java-21-openjdk/bin/java
alternatives --set javac /usr/lib/jvm/java-21-openjdk/bin/javac

# Verify Java
java -version

# Install Jenkins
dnf install -y jenkins

# Create Jenkins log directory
mkdir -p /var/log/jenkins
chown -R jenkins:jenkins /var/log/jenkins

# Start Jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

# Verify Jenkins
systemctl status jenkins --no-pager

# Verify Jenkins Port
ss -tulpn | grep 8080

# Display Initial Admin Password
cat /var/lib/jenkins/secrets/initialAdminPassword
