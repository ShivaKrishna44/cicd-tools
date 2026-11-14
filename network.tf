# ==========================================
# network.tf : where the instances go
# ==========================================
# Why this file exists. The old setup hard-coded one subnet and one security group, and they
# did not belong together: the subnet was in us-east-1e (no t3 instances there), and the
# security group sat in a VPC that has no subnets at all. Now nothing is hard-coded:
#   1. find the zones where BOTH instance types are offered
#   2. pick a subnet in the default VPC in one of those zones
#   3. create a security group in the SAME VPC as that subnet
# To use your own network instead, set subnet_id (and security_group_ids from the same VPC).

# The "http" provider (used below to read your public IP) is declared in provider.tf,
# because a folder may have only one required_providers block.

# ------------------------------------------
# 1. Zones that offer both instance types
# ------------------------------------------
data "aws_ec2_instance_type_offerings" "jenkins" {
  location_type = "availability-zone"

  filter {
    name   = "instance-type"
    values = [var.jenkins_instance_type]
  }
}

data "aws_ec2_instance_type_offerings" "agent" {
  location_type = "availability-zone"

  filter {
    name   = "instance-type"
    values = [var.agent_instance_type]
  }
}

locals {
  supported_azs = tolist(setintersection(
    toset(data.aws_ec2_instance_type_offerings.jenkins.locations),
    toset(data.aws_ec2_instance_type_offerings.agent.locations),
  ))
}

# ------------------------------------------
# 2. Subnet (default VPC, supported zone)
# ------------------------------------------
data "aws_vpc" "default" {
  count   = var.subnet_id == null ? 1 : 0
  default = true
}

data "aws_subnets" "usable" {
  count = var.subnet_id == null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }

  filter {
    name   = "availability-zone"
    values = local.supported_azs
  }
}

locals {
  # sort() keeps the choice stable. try() turns "nothing found" into null, so the check on each
  # instance can print a clear message instead of an index error.
  subnet_id = var.subnet_id != null ? var.subnet_id : try(sort(data.aws_subnets.usable[0].ids)[0], null)
}

# Read the chosen subnet back, so the security group is always created in ITS vpc.
data "aws_subnet" "chosen" {
  count = local.subnet_id != null ? 1 : 0
  id    = local.subnet_id
}

locals {
  vpc_id    = try(data.aws_subnet.chosen[0].vpc_id, null)
  subnet_az = try(data.aws_subnet.chosen[0].availability_zone, null)
  create_sg = length(var.security_group_ids) == 0
}

# ------------------------------------------
# 3. Security group (same VPC as the subnet)
# ------------------------------------------
# Your current public IP, used so SSH and the Jenkins UI are NOT open to the whole internet.
# Skipped when you pass allowed_cidrs yourself, or when you bring your own security group.
data "http" "my_ip" {
  count = local.create_sg && length(var.allowed_cidrs) == 0 ? 1 : 0
  url   = "https://checkip.amazonaws.com"

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}$", chomp(self.response_body)))
      error_message = "Could not read your public IP from checkip.amazonaws.com. Pass it yourself, for example: terraform plan -var 'allowed_cidrs=[\"203.0.113.7/32\"]'"
    }
  }
}

locals {
  allowed_cidrs = !local.create_sg ? [] : (
    length(var.allowed_cidrs) > 0 ? var.allowed_cidrs : ["${chomp(data.http.my_ip[0].response_body)}/32"]
  )
  security_group_ids = local.create_sg ? [aws_security_group.jenkins[0].id] : var.security_group_ids
}

resource "aws_security_group" "jenkins" {
  count       = local.create_sg ? 1 : 0
  name_prefix = "jenkins-lab-"
  description = "Jenkins server and agent. SSH and the Jenkins UI from allowed IPs only."
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidrs
  }

  ingress {
    description = "Jenkins UI from allowed IPs"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidrs
  }

  ingress {
    description = "Server and agent talk to each other inside this group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "All outbound (package installs, Git, ECR)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "jenkins-lab"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
