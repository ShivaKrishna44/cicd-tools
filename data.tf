data "aws_ami" "ami_info" {
  most_recent = true
  owners      = ["137112412989"] # Official Amazon Account ID

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"] # Finds the latest stable AL2023 release
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

