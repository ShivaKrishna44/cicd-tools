#!/bin/bash
set -e

echo "===== Expanding Root Volume ====="
if lsblk | grep -q nvme0n1p1; then
    growpart /dev/nvme0n1 1 || true
    if df -T / | grep -q xfs; then
        xfs_growfs /
    else
        resize2fs /dev/nvme0n1p1
    fi
fi

echo "===== Installing Packages ====="
# Switched to Java 21 to satisfy the latest Jenkins requirements
dnf install -y git wget fontconfig java-21-openjdk java-21-openjdk-devel

echo "===== Configuring Jenkins Repository ====="
rm -f /etc/yum.repos.d/jenkins.repo

cat <<EOF > /etc/yum.repos.d/jenkins.repo
[jenkins]
name=Jenkins-stable
baseurl=https://jenkins.io
gpgcheck=1
EOF

# Correctly formatted key import
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
