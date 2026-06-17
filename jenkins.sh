#!/bin/bash
#!/bin/bash
set -euxo pipefail

#Option	Meaning
#-e	Exit on command failure
#-u	Error on undefined variables
#-x	Print commands as they execute
#-o pipefail	Fail if any command in a pipe fails

growpart /dev/nvme0n1 4 || true

pvresize /dev/nvme0n1p4 || true

lvextend -L +10G /dev/mapper/RootVG-homeVol || true
lvextend -L +10G /dev/mapper/RootVG-varVol || true
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol || true

xfs_growfs /home || true
xfs_growfs /var || true
xfs_growfs /var/tmp || true

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
