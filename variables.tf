variable "zone_name" {
  type        = string
  default     = "vosukula.online"
  description = "Route53 hosted zone domain name"
}

variable "route53_zone_id" {
  type        = string
  default     = "Z06069392VYRLP2HMDXLV"
  description = "Route53 hosted zone ID for vosukula.online"
}

variable "jenkins_dns_name" {
  type        = string
  default     = "jenkins-ec2"
  description = "DNS name for the Jenkins server, added under zone_name. Not 'jenkins': that name is owned by the EKS ingress CNAME and an A record cannot share it."

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.jenkins_dns_name))
    error_message = "jenkins_dns_name must be a single DNS label: lowercase letters, digits and hyphens."
  }
}

variable "agent_dns_name" {
  type        = string
  default     = "jenkins-agent"
  description = "DNS name for the Jenkins agent, added under zone_name."

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.agent_dns_name))
    error_message = "agent_dns_name must be a single DNS label: lowercase letters, digits and hyphens."
  }
}

variable "jenkins_instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for Jenkins server. The subnet is picked in a zone that offers it."
}

variable "agent_instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for Jenkins agent. The subnet is picked in a zone that offers it."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "Optional. Leave it unset and a subnet is picked in the default VPC, in a zone that offers both instance types. Set it only to force one specific subnet."
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Optional. Leave it empty and a security group is created in the same VPC as the subnet. If you set it, the groups must be in the same VPC as the subnet."
}

variable "allowed_cidrs" {
  type        = list(string)
  default     = []
  description = "Who may reach SSH (22) and Jenkins (8080) on the created security group. Leave it empty to allow only your current public IP. Use [\"0.0.0.0/0\"] only if you really want it open to everyone."

  validation {
    condition     = alltrue([for c in var.allowed_cidrs : can(cidrhost(c, 0))])
    error_message = "Every entry in allowed_cidrs must be a valid CIDR, for example 203.0.113.7/32."
  }
}
