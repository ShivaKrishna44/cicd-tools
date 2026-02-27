
#data "aws_ami" "ami_info" {
#    most_recent = true
#    owners = ["658643245214"]
#    filter {
#        name   = "name"
#        values = ["Redhat-9-DevOps-Practice"]
#    }
#    filter {
#        name   = "root-device-type"
#        values = ["ebs"]
#    }
#    filter {
#        name   = "virtualization-type"
#        values = ["hvm"]
#    }
#}
#3data "aws_ami" "ami_info" {
#  most_recent = true
#  owners      = ["309956199498"] # Red Hat official

#  filter {
#    name   = "name"
#    values = ["RHEL-9.*_HVM-*x86_64*"]
#  }
#}
#Reasons:
#RHEL requires subscription handling
#Some third-party repos behave differently
#Extra entitlement checks
#Enterprise restrictions
#For CI/CD lab practice, this is unnecessary complexity.


data "aws_ami" "ami_info" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
