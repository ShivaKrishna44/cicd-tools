data "aws_ami" "ami_info" {
  most_recent = true
  owners      = ["309956199498"] # Official Amazon Red Hat Account ID

  filter {
    name   = "name"
    values = ["RHEL-9.*-x86_64-*Hourly*"] # Finds the latest standard RHEL 9 x86_64 image
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

