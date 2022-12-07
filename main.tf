terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.your_region
}

resource "aws_security_group" "minecraft" {
  ingress {
    description = "Receive SSH from home."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Receive Minecraft from everywhere."
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"  
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Send everywhere."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Minecraft"
  }
}

/*
resource "aws_key_pair" "home" {
  key_name   = "Home"
  public_key = var.your_public_key
}
*/

resource "aws_key_pair" "minecraft-ec2" {
  key_name   = "kp-ec2-minecraft"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt70hApW6M8hFhI1A6sloQ6Zv1gByI7wXqB5tgTD3Ue"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "minecraft" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "c6g.medium"
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.minecraft-ec2.key_name
  user_data                   = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt -y upgrade
    EOF
  tags = {
    Name = "Minecraft"
  }
}

resource "aws_eip_association" "eip_assoc_minecraft" {
  allocation_id = "eipalloc-0e5c60af075b2f9ed"
  instance_id = aws_instance.minecraft.id
}

output "instance_ip_addr" {
  value = aws_instance.minecraft.public_ip
}
