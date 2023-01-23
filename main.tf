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
  region  = var.region
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
    Name        = "minecraft"
    Environment = "dev"
  }
}

// Create policy to read and write S3
resource "aws_iam_policy" "s3-policy" {
  name        = "s3-Bucket-Access-Policy"
  description = "Provides permission to read and write S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::*" ]
      },
    ]
  })
}

// Create an IAM Role
resource "aws_iam_role" "s3-read-role" {
  name = "ec2_s3-read-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

// attach policy to role
resource "aws_iam_policy_attachment" "minecraft-role-attachment" {
  name       = "minecraft-role-attachment"
  roles      = [aws_iam_role.s3-read-role.name]
  policy_arn = aws_iam_policy.s3-policy.arn
}

// Need to create instance profile
resource "aws_iam_instance_profile" "minecraft-role-profile" {
  name = "minecraft-role-profile"
  role = aws_iam_role.s3-read-role.name
}

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
  instance_type               = "c7g.medium"
  iam_instance_profile        = aws_iam_instance_profile.minecraft-role-profile.name
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.minecraft-ec2.key_name
  user_data                   = <<-EOF
    #!/bin/bash

    sudo apt update
    sudo apt -y upgrade

    wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - 
    sudo add-apt-repository -y 'deb https://apt.corretto.aws stable main'
    sudo apt-get install -y java-17-amazon-corretto-jdk    

    apt-get install -y awscli
    aws configure list

    cd .
    curl https://raw.githubusercontent.com/dylanclement/terraform-minecraft/main/backup.sh > /home/ubuntu/backup.sh
    sudo chown ubuntu:ubuntu /home/ubuntu/backup.sh
    sudo chmod +x backup.sh

    cat <(sudo crontab -u ubuntu -l) <(echo "2 2 * * * /bin/bash /home/ubuntu/backup.sh") | sudo crontab -u ubuntu -

    sudo mkdir -p /opt/minecraft/server
    sudo mkdir -p /opt/minecraft/backups
    cd /opt/minecraft/server

    aws s3 sync s3://086133709882-minecraft-server-1 .
    FILE=`aws s3api list-objects-v2 --bucket "086133709882-minecraft-backup-1" --query 'reverse(sort_by(Contents[?contains(Key, \`gz\`)], &LastModified))[:1].Key' --output=text`
    aws s3 cp "s3://086133709882-minecraft-backup-1/$FILE" .
    tar -xf $FILE

    sudo chown -R ubuntu:ubuntu /opt/minecraft
    sudo chmod +x server.sh

    sudo -u ubuntu /usr/bin/tmux new -s minecraft-server -d "/bin/bash server.sh"
    EOF
  tags = {
    Name        = "minecraft"
    Environment = "dev"
  }
}

resource "aws_eip_association" "eip_assoc_minecraft" {
  allocation_id = "eipalloc-0e5c60af075b2f9ed"
  instance_id = aws_instance.minecraft.id
}

output "instance_ip_addr" {
  value = aws_instance.minecraft.public_ip
}
