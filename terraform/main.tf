provider "aws" {
  region = "us-east-1"
}

#  DYNAMIC AMI FETCHING FOR UBUNTU
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "cat"  # replace with your AWS key pair

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io -y
              systemctl start docker
              docker run -d -p 80:5000 yourdockerhubusername/myflaskapp:latest
              EOF

  tags = {
    Name = "flask-app-instance"
  }
}
