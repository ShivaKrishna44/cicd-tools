# ==========================================
# Jenkins + Jenkins Agent EC2 Instances
# ==========================================
# The network (subnet, security group, your IP) is chosen in network.tf.

# ==========================================
# Dynamic AMI Lookup (Prevents Expired AMI Errors)
# ==========================================
data "aws_ami" "practice" {
  most_recent = true
  owners      = ["973714476881"]

  filter {
    name   = "name"
    values = ["Redhat-9-DevOps-Practice*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==========================================
# Jenkins + Jenkins Agent EC2 Instances
# ==========================================

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.practice.id
  instance_type               = var.jenkins_instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = local.security_group_ids
  associate_public_ip_address = true
  # key_name                  = var.key_name # Optional: course AMI has built-in login

  # IMDSv2 only: blocks the common "steal credentials through the metadata service" route.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    precondition {
      condition     = local.subnet_id != null
      error_message = "No subnet found in the default VPC in a zone that offers both ${var.jenkins_instance_type} and ${var.agent_instance_type}. The default VPC may not exist in this region. Set subnet_id to a subnet you choose, and security_group_ids from the same VPC."
    }
  }

  user_data                   = file("${path.module}/jenkins.sh")
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
  ami                         = data.aws_ami.practice.id
  instance_type               = var.agent_instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = local.security_group_ids
  associate_public_ip_address = true
  # key_name                  = var.key_name # Optional: course AMI has built-in login

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    precondition {
      condition     = local.subnet_id != null
      error_message = "No subnet found in the default VPC in a zone that offers both ${var.jenkins_instance_type} and ${var.agent_instance_type}. The default VPC may not exist in this region. Set subnet_id to a subnet you choose, and security_group_ids from the same VPC."
    }
  }

  user_data                   = file("${path.module}/jenkins-agent.sh")
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
# NOTE: jenkins.vosukula.online already has a CNAME that the ALB Ingress Controller owns (the
# Jenkins that runs inside EKS). Route53 does not allow an A record and a CNAME on one name,
# so these two instances use different names. The EKS record is not touched.
#   Jenkins server -> jenkins-ec2.vosukula.online   (var.jenkins_dns_name)
#   Jenkins agent  -> jenkins-agent.vosukula.online (var.agent_dns_name)
# The IPs are public and change when an instance is replaced. Terraform updates the records.
# allow_overwrite = true: if an old record with the same name and type is left from an
# earlier run, Terraform takes it over instead of failing with "already exists".

resource "aws_route53_record" "jenkins" {
  zone_id         = var.route53_zone_id
  name            = "${var.jenkins_dns_name}.${var.zone_name}"
  type            = "A"
  ttl             = 60
  allow_overwrite = true
  records         = [aws_instance.jenkins.public_ip]
}

resource "aws_route53_record" "jenkins_agent" {
  zone_id         = var.route53_zone_id
  name            = "${var.agent_dns_name}.${var.zone_name}"
  type            = "A"
  ttl             = 60
  allow_overwrite = true
  records         = [aws_instance.jenkins_agent.public_ip]
}

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

output "jenkins_url" {
  description = "Open this in a browser (only from an allowed IP). Jenkins takes 5 to 10 minutes after boot."
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_dns_url" {
  description = "Jenkins by name (only reachable from an allowed IP)."
  value       = "http://${aws_route53_record.jenkins.fqdn}:8080"
}

output "jenkins_agent_dns" {
  description = "DNS name of the Jenkins agent."
  value       = aws_route53_record.jenkins_agent.fqdn
}

output "jenkins_private_ip" {
  description = "Private IP of the Jenkins server. The agent should connect to this one."
  value       = aws_instance.jenkins.private_ip
}

# What the automatic network pick chose, so there is no guessing.
output "network_pick" {
  description = "Values behind the automatic network pick."
  value = {
    vpc                  = local.vpc_id
    subnet               = local.subnet_id
    zone                 = local.subnet_az
    security_groups      = local.security_group_ids
    allowed_cidrs        = local.allowed_cidrs
    zones_for_both_types = local.supported_azs
  }
}
