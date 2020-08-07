provider "aws" {
  region = "us-east-1"
}


data "aws_security_group" "default" {
  tags = {
    Name = "Default"
  }
}


resource "aws_instance" "centos7" {
  # us-east-1 official AMI
  # https://wiki.centos.org/Cloud/AWS
  ami = "ami-06cf02a98a61f9f5e"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ data.aws_security_group.default.id ]
  key_name = "brandon"
  user_data = file("user-data.sh")

  root_block_device {
    volume_size = 20
    encrypted = true
  }

  tags = {
    Name = "CentOS7-vulns"
    Owner = "Brandon"
  }
}