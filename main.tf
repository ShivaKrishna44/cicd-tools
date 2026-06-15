
module "jenkins" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0b7658fc6ffcc0172"]   #replace your SG
  subnet_id              = "subnet-01f5e8f84851593f3" #replace your Subnet
  ami                    = data.aws_ami.ami_info.id
  user_data              = file("jenkins.sh")

  # PASS KEY NAME AS A SIMPLE STRING
  key_name               = "dev-ops-key" 

  tags = {
    Name = "jenkins"
  }

  # Define the root volume size and type
  root_block_device = {
    volume_size           = 50    # Size of the root volume in GB
    volume_type           = "gp3" # General Purpose SSD (you can change it if needed)
    delete_on_termination = true  # Automatically delete the volume when the instance is terminated
  }
}

module "jenkins_agent" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0b7658fc6ffcc0172"]   #replace your SG
  subnet_id              = "subnet-01f5e8f84851593f3" #replace your Subnet
  ami                    = data.aws_ami.ami_info.id
  user_data              = file("jenkins-agent.sh")

  # PASS KEY NAME AS A SIMPLE STRING
  key_name               = "dev-ops-key" 

  tags = {
    Name = "jenkins-agent"
  }

  root_block_device = {
    volume_size           = 50    # Size of the root volume in GB
    volume_type           = "gp3" # General Purpose SSD (you can change it if needed)
    delete_on_termination = true  # Automatically delete the volume when the instance is terminated
  }
}


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name = "jenkins"
      type = "A"
      ttl  = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name = "jenkins-agent"
      type = "A"
      ttl  = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    }
  ]

}


output "jenkins_ssh_command" {
  description = "Copy and paste this command to connect to the Jenkins server"
  value       = "ssh -i /c/Devops/dev-ops-key.pem ec2-user@${module.jenkins.public_ip}"
}

output "jenkins_agent_ssh_command" {
  description = "Copy and paste this command to connect to the Jenkins Agent"
  value       = "ssh -i /c/Devops/dev-ops-key.pem ec2-user@${module.jenkins_agent.public_ip}"
}


#jenkins_agent_ssh_command = "ssh -i /c/Devops/dev-ops-key.pem ec2-user@3.95.159.127"
#jenkins_ssh_command = "ssh -i /c/Devops/dev-ops-key.pem ec2-user@54.175.228.125"