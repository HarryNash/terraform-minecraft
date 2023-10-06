resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "minecraft" {
  vpc_id        = aws_default_vpc.default.id
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