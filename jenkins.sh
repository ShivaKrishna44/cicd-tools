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

# Jenkins Repository
curl -fsSL -o /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

dnf clean all
dnf makecache

dnf install -y java-21-openjdk java-21-openjdk-devel fontconfig

alternatives --set java /usr/lib/jvm/java-21-openjdk/bin/java

java -version

dnf install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# Verify Jenkins
systemctl status jenkins --no-pager

# Verify Jenkins Port
ss -tulpn | grep 8080

# Display Initial Admin Password
cat /var/lib/jenkins/secrets/initialAdminPassword
