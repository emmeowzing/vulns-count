provider "aws" {
  region = "us-east-1"
}


data "aws_security_group" "default" {
  tags = {
    Name = "Default"
  }
}


data "aws_ami" "ubuntu18" {
  most_recent = true
  owners = [ "099720109477" ]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}


resource "aws_instance" "ubuntu18" {
  ami = data.aws_ami.ubuntu18.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [ data.aws_security_group.default.id ]
  key_name = "brandon"
  user_data = file("user-data.sh")

  root_block_device {
    volume_size = 20
    encrypted = true
  }

  tags = {
    Name = "Ubuntu18-vulns"
    Owner = "Brandon"
  }
}