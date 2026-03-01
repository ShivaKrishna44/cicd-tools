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
dnf update -y
dnf install -y git java-17-amazon-corretto wget

echo "===== Configuring Jenkins Repository (AL2023 Compatible) ====="
rm -f /etc/yum.repos.d/jenkins.repo

cat <<EOF > /etc/yum.repos.d/jenkins.repo
[jenkins]
name=Jenkins
baseurl=https://pkg.jenkins.io/rpm-stable
enabled=1
gpgcheck=0
EOF

dnf clean all
dnf makecache

echo "===== Installing Jenkins ====="
dnf install -y jenkins

echo "===== Starting Jenkins ====="
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "===== Jenkins Installation Complete ====="