
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

data "aws_ami" "ami_info" {
  most_recent = true
  owners      = ["658643245214"] # Red Hat official

  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*x86_64*"]
  }
}
