#!/bin/bash
set -e

echo "===== Resizing Disk ====="
growpart /dev/nvme0n1 4 || true

lvextend -L +10G /dev/RootVG/rootVol || true
lvextend -L +10G /dev/mapper/RootVG-varVol || true
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol || true

xfs_growfs / || true
xfs_growfs /var || true
xfs_growfs /var/tmp || true

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