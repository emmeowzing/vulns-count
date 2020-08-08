provider "aws" {
  region = "us-east-1"
}


data "aws_security_group" "default" {
  tags = {
    Name = "Default"
  }
}


resource "aws_instance" "al1" {
  ami = "ami-09d8b5222f2b93bf0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ data.aws_security_group.default.id ]
  key_name = "brandon"
  user_data = file("user-data.sh")

  root_block_device {
    volume_size = 20
    encrypted = true
  }

  tags = {
    Name = "AL2-vulns"
    Owner = "Brandon"
  }
}