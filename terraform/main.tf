provider "aws" {
  region = "us-west-2"  # change if you're using a different region
}

resource "aws_instance" "minecraft_server" {
  ami           = "ami-0e731c8a588258d0d"  # linux 2 ami
  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = "minecraft-key"  # won't be used since no SSH

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
    cidr_blocks = ["0.0.0.0/0"]  # allow everyone
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
