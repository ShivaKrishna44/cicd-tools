#!/bin/bash
set -euxo pipefail

# Extend partition

growpart /dev/nvme0n1 4

# Extend LVM volumes

lvextend -L +10G /dev/mapper/RootVG-homeVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

# Grow filesystems

xfs_growfs /home
xfs_growfs /var
xfs_growfs /var/tmp

# Install Java 21 (recommended for latest Jenkins)

dnf install -y java-21-openjdk java-21-openjdk-devel

alternatives --set java /usr/lib/jvm/java-21-openjdk/bin/java
alternatives --set javac /usr/lib/jvm/java-21-openjdk/bin/javac

# Terraform

dnf install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
dnf install -y terraform

# NodeJS

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install -y nodejs

# Utilities

dnf install -y zip unzip git wget curl

# Docker

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

dnf install -y 
docker-ce 
docker-ce-cli 
containerd.io 
docker-buildx-plugin 
docker-compose-plugin

systemctl enable docker
systemctl start docker

# Add users to docker group

usermod -aG docker ec2-user

# Verify installations

java -version
terraform version
node -v
npm -v
docker --version
docker compose version

echo "Jenkins Agent setup completed successfully"
