#!/bin/bash
set -e

echo "===== Expanding Root Volume (if resized in AWS) ====="

if lsblk | grep -q nvme0n1p1; then
    growpart /dev/nvme0n1 1 || true
    if df -T / | grep -q xfs; then
        xfs_growfs /
    else
        resize2fs /dev/nvme0n1p1
    fi
fi

echo "===== Installing Packages ====="
dnf clean all
dnf update -y
#dnf install -y git java-17-amazon-corretto wget
dnf install -y git wget fontconfig java-21-amazon-corretto

echo "===== Configuring Jenkins Repository (AL2023 Compatible) ====="
rm -f /etc/yum.repos.d/jenkins.repo

cat <<EOF > /etc/yum.repos.d/jenkins.repo
[jenkins]
name=Jenkins-stable
baseurl=https://jenkins.io
#enabled=1
gpgcheck=0
EOF

# Import the correct verification key file path
rpm --import https://jenkins.iojenkins.io-2023.key

dnf clean all
dnf makecache

echo "===== Installing Jenkins ====="
dnf install -y jenkins

echo "===== Starting Jenkins ====="
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "===== Jenkins Installation Complete ====="