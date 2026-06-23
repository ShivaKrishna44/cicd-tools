# ==========================================
# Jenkins + Jenkins Agent EC2 Instances
# ==========================================

resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.jenkins_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  user_data = file("jenkins.sh")

  # Replace instance when user_data changes
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 70
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "jenkins"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami                    = var.ami_id
  instance_type          = var.agent_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  user_data = file("jenkins-agent.sh")

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "jenkins-agent"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# ==========================================
# Route53 DNS Records
# ==========================================
# NOTE: These records are commented out because jenkins.vosukula.online
# already has a CNAME record managed by the ALB Ingress Controller.
# Creating an A record with the same name is not permitted by Route53.
# Options:
#   1. Delete the existing CNAME via AWS console/CLI and uncomment these blocks
#   2. Leave DNS managed by the ALB Ingress Controller (recommended if using EKS)

# resource "aws_route53_record" "jenkins" {
#   zone_id         = var.route53_zone_id
#   name            = "jenkins.${var.zone_name}"
#   type            = "A"
#   ttl             = 60
#   allow_overwrite = true
#   records         = [aws_instance.jenkins.public_ip]
# }

# resource "aws_route53_record" "jenkins_agent" {
#   zone_id         = var.route53_zone_id
#   name            = "jenkins-agent.${var.zone_name}"
#   type            = "A"
#   ttl             = 60
#   allow_overwrite = true
#   records         = [aws_instance.jenkins_agent.public_ip]
# }

# ==========================================
# Outputs
# ==========================================

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_agent_public_ip" {
  description = "Public IP of the Jenkins agent"
  value       = aws_instance.jenkins_agent.public_ip
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.jenkins.public_ip}"
}

output "jenkins_agent_ssh_command" {
  description = "SSH command to connect to Jenkins agent"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.jenkins_agent.public_ip}"
}

output "jenkins_url" {
  description = "Jenkins web UI URL"
  value       = "http://jenkins.${var.zone_name}:8080"
}
