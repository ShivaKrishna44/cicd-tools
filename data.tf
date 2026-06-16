
data "aws_ami" "ami_info" {
  most_recent = true
  # Official Rocky Linux Organization Account ID
  owners      = ["792107900819"] 

  filter {
    name   = "name"
    values = ["Rocky-9-EC2-Base-*.x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

