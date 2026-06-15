##!/bin/bash

#resize disk from 20GB to 50GB
#growpart /dev/nvme0n1 4

#lvextend -L +10G /dev/RootVG/rootVol
#lvextend -L +10G /dev/mapper/RootVG-varVol
#lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

#xfs_growfs /
#xfs_growfs /var/tmp
#xfs_growfs /var

#curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
##rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
#yum install fontconfig java-17-openjdk jenkins -y
#yum install jenkins -y
#systemctl daemon-reload
#systemctl enable jenkins
#systemctl start jenkins

#!/bin/bash
dnf install wget
# Send all output to a log file for easier debugging if anything fails
exec > >(tee /var/log/user-data.log|logger -t user-data -s2) 2>&1

echo "=== Starting Jenkins Installation Workflow ==="

# 1. Enable official AWS-provided Red Hat channels (Bypasses Subscription Manager)
echo "--> Enabling RHUI repositories..."
dnf config-manager --set-enabled rhui-REGION-rhel-9-for-x86_64-baseos-rhui-rpms
dnf config-manager --set-enabled rhui-REGION-rhel-9-for-x86_64-appstream-rhui-rpms

# 2. Install basic system utility packages
echo "--> Installing baseline utilities..."
dnf install wget fontconfig -y

# 3. Securely pull down the official Jenkins package repository
echo "--> Downloading Jenkins repository tracker..."
wget -O /etc/yum.repos.d/jenkins.repo https://jenkins.io

# 4. Import the official Jenkins cryptographic validation signature key
echo "--> Importing Jenkins GPG authentication key..."
rpm --import https://jenkins.io

# 5. Install the correct Java 21 environment alongside Jenkins core binaries
echo "--> Executing package installation block (Java 21 + Jenkins)..."
dnf install java-21-openjdk java-21-openjdk-devel jenkins -y

# 6. Ensure the global environment defaults directly to Java 21 execution
echo "--> Re-linking core system alternatives..."
alternatives --set java /usr/lib/jvm/jre-21-openjdk/bin/java

# 7. Create explicit operational logging folders and assign permissions
echo "--> Creating required directories and applying permissions..."
mkdir -p /var/log/jenkins
chown -R jenkins:jenkins /var/lib/jenkins /var/cache/jenkins /var/log/jenkins

# 8. Reload system structures, set to run on boot, and start the engine
echo "--> Starting Jenkins system service thread..."
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

echo "=== Jenkins Installation Workflow Finished Successfully! ==="
