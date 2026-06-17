provider "aws" {
region = "us-east-1"
}

resource "aws_instance" "jenkins" {
ami                    = "ami-0220d79f3f480ecf5"
instance_type          = "t3.small"
subnet_id              = "subnet-01f5e8f84851593f3"
vpc_security_group_ids = ["sg-0b7658fc6ffcc0172"]
key_name               = "dev-ops-key"

user_data = file("jenkins.sh")

root_block_device {
volume_size           = 70
volume_type           = "gp3"
delete_on_termination = true
}

tags = {
Name = "jenkins"
}
}

resource "aws_instance" "jenkins_agent" {
ami                    = "ami-0220d79f3f480ecf5"
instance_type          = "t3.small"
subnet_id              = "subnet-01f5e8f84851593f3"
vpc_security_group_ids = ["sg-0b7658fc6ffcc0172"]
key_name               = "dev-ops-key"

user_data = file("jenkins-agent.sh")

root_block_device {
volume_size           = 50
volume_type           = "gp3"
delete_on_termination = true
}

tags = {
Name = "jenkins-agent"
}
}

resource "aws_route53_record" "jenkins" {
zone_id = "Z06069392VYRLP2HMDXLV"
name    = "jenkins.vosukula.online"
type    = "A"
ttl     = 1

records = [
aws_instance.jenkins.public_ip
]
}

resource "aws_route53_record" "jenkins_agent" {
zone_id = "Z06069392VYRLP2HMDXLV"
name    = "jenkins-agent.vosukula.online"
type    = "A"
ttl     = 1

records = [
aws_instance.jenkins_agent.public_ip
]
}

output "jenkins_ssh_command" {
value = "ssh -i /c/Devops/dev-ops-key.pem ec2-user@${aws_instance.jenkins.public_ip}"
}

output "jenkins_agent_ssh_command" {
value = "ssh -i /c/Devops/dev-ops-key.pem ec2-user@${aws_instance.jenkins_agent.public_ip}"
}
