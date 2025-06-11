provider "aws" {
  region = "us-west-2"
}

# EC2 Instance
resource "aws_instance" "minecraft_server" {
  ami                         = "ami-00755a52896316cee"  # Amazon Linux 2 (confirmed working)
  instance_type               = "t3.small"
  vpc_security_group_ids      = [aws_security_group.minecraft_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "minecraft-server"
  }
}

# Security Group to open Minecraft port
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_sg"
  description = "Allow Minecraft port"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach SSM policy to the role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile for EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

# Output public IP
output "public_ip" {
  value = aws_instance.minecraft_server.public_ip
}
