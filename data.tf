data "aws_ami" "ami_info" {
<<<<<<< HEAD
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
=======

    most_recent = true
    owners = ["973714476881"]

    filter {
        name   = "name"
        values = ["RHEL-9-DevOps-Practice"]
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
>>>>>>> b32708653183fc9134b4816d0e56892467f73adc
