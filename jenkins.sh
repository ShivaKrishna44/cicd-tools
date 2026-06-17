#!/bin/bash
set -euxo pipefail

echo "========== Starting Jenkins Setup =========="

############################################

# Disk Expansion

############################################

growpart /dev/nvme0n1 4 || true

pvresize /dev/nvme0n1p4 || true

VFREE=$(vgs --noheadings -o vg_free --units g RootVG | tr -d ' ' | cut -d. -f1)

if [ "$VFREE" -gt 1 ]; then
echo "Extending logical volumes..."

```
lvextend -L +10G /dev/mapper/RootVG-homeVol || true
lvextend -L +10G /dev/mapper/RootVG-varVol || true
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol || true

xfs_growfs /home || true
xfs_growfs /var || true
xfs_growfs /var/tmp || true
```

else
echo "No free space available in RootVG. Skipping LV extension."
fi

############################################

# Java 21 Installation

############################################

if ! java -version 2>&1 | grep -q "21"; then
dnf install -y java-21-openjdk java-21-openjdk-devel fontconfig

```
alternatives --set java /usr/lib/jvm/java-21-openjdk/bin/java
alternatives --set javac /usr/lib/jvm/java-21-openjdk/bin/javac
```

fi

java -version

############################################

# Jenkins Repository

############################################

if [ ! -f /etc/yum.repos.d/jenkins.repo ]; then
curl -fsSL 
-o /etc/yum.repos.d/jenkins.repo 
https://pkg.jenkins.io/redhat-stable/jenkins.repo

```
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
```

fi

############################################

# Jenkins Installation

############################################

if ! rpm -qa | grep -q "^jenkins"; then
dnf clean all
dnf makecache
dnf install -y jenkins
fi

############################################

# Jenkins Service

############################################

systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

sleep 15

############################################

# Validation

############################################

systemctl is-active jenkins

ss -tulpn | grep 8080

echo "Jenkins Initial Password:"
cat /var/lib/jenkins/secrets/initialAdminPassword

echo "========== Jenkins Setup Completed =========="
