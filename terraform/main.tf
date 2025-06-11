provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "minecraft_server" {
  ami           = "ami-00755a52896316cee"  # confirmed to exist in Learner Lab
  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = "minecraft-key"

  tags = {
    Name = "minecraft-server"
  }
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_sg"
  description = "Allow Minecraft port"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
