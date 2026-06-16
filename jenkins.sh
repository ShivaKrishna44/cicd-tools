#!/bin/bash

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
curl -fsSL -o /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Refresh repositories
dnf clean all
dnf makecache

# Install Java
dnf install -y java-17-openjdk fontconfig

# Install Jenkins
dnf install -y jenkins

# Start Jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# Verify
systemctl status jenkins --no-pager

#incase if u see pulgin error in web page
#vi /usr/lib/systemd/system/jenkins.service

#Scroll down using your arrow keys until you locate the line that starts with Environment="JAVA_OPTS=.

#Djenkins.install.runSetupWizard=false directly inside the quotes:

#Change the line to look exactly like this:

#Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"

#Reload and Reboot the Service Engine
#Apply your environment changes and restart Jenkins to apply the configuration:

#systemctl daemon-reload
#systemctl restart jenkins
