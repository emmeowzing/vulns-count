provider "aws" {
  region = "us-east-1"
}


data "aws_security_group" "default" {
  tags = {
    Name = "Private"
  }
}


resource "aws_instance" "al2" {
  ami = "ami-02354e95b39ca8dec"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ data.aws_security_group.default.id ]
  key_name = "brandon"
  user_data = file("user-data.sh")

  root_block_device {
    volume_size = 20
    encrypted = true
  }

  tags = {
    Name = "AL1-vulns"
    Owner = "Brandon"
  }
}