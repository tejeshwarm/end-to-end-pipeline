provider "aws" {
  region = "ap-southeast-2"
}

# ✅ Get latest Ubuntu 20.04 AMI
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

# ✅ Security Group with SSH (22) and Flask (5000) open
resource "aws_security_group" "allow_flask" {
  name        = "flask_5000_sg"
  description = "Allow inbound Flask traffic on port 5000 and SSH on port 22"

  # Allow Flask traffic
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ EC2 instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "cat" # must match your AWS key pair
  vpc_security_group_ids = [aws_security_group.allow_flask.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io -y
              systemctl start docker
              docker run -d -p 5000:5000 tejeshwarofficial/flask-app:latest
              EOF

  tags = {
    Name = "flask-app-instance"
  }
}
