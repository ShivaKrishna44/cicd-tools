#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>&1)

echo "========== Starting Jenkins Agent Setup =========="

############################################
# Disk Expansion
############################################

growpart /dev/nvme0n1 4 || true
pvresize /dev/nvme0n1p4 || true

VFREE=$(vgs --noheadings -o vg_free --units g RootVG 2>/dev/null | tr -d ' ' | cut -d. -f1 || echo "0")

if [ "${VFREE:-0}" -gt 1 ]; then
  echo "Extending logical volumes..."
  lvextend -L +10G /dev/mapper/RootVG-homeVol || true
  lvextend -L +10G /dev/mapper/RootVG-varVol || true
  lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol || true

  xfs_growfs /home || true
  xfs_growfs /var || true
  xfs_growfs /var/tmp || true
else
  echo "No free space in RootVG. Skipping LV extension."
fi

############################################
# Java 21
############################################

dnf install -y java-21-openjdk java-21-openjdk-devel

alternatives --set java  /usr/lib/jvm/java-21-openjdk/bin/java
alternatives --set javac /usr/lib/jvm/java-21-openjdk/bin/javac

java -version

############################################
# Terraform
############################################

dnf install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
dnf install -y terraform

terraform version

############################################
# NodeJS 20
############################################

dnf module disable nodejs -y || true
dnf module enable nodejs:20 -y
dnf install -y nodejs

node -v
npm -v

############################################
# Utilities
############################################

dnf install -y zip unzip git wget curl

############################################
# Docker
############################################

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

dnf install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

systemctl enable docker
systemctl start docker

# Add users to docker group so they can run docker without sudo
usermod -aG docker ec2-user
# Also add jenkins user if it exists (for Jenkins agent process)
id jenkins &>/dev/null && usermod -aG docker jenkins || true

############################################
# Verify all installations
############################################

java -version
terraform version
node -v
npm -v
docker --version
docker compose version

echo "========== Jenkins Agent Setup Completed =========="
