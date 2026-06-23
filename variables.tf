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

variable "ami_id" {
  type        = string
  default     = "ami-0220d79f3f480ecf5"
  description = "AMI ID for Jenkins and Jenkins agent EC2 instances (RHEL/Amazon Linux in us-east-1)"
}

variable "jenkins_instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for Jenkins server"
}

variable "agent_instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for Jenkins agent"
}

variable "subnet_id" {
  type        = string
  default     = "subnet-01f5e8f84851593f3"
  description = "Subnet ID where Jenkins instances will be launched"
}

variable "security_group_ids" {
  type        = list(string)
  default     = ["sg-0b7658fc6ffcc0172"]
  description = "Security group IDs to attach to Jenkins instances"
}

variable "key_name" {
  type        = string
  default     = "dev-ops-key"
  description = "EC2 key pair name for SSH access"
}
