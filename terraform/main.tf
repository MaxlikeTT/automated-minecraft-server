provider "aws" {
  region = "us-west-2"
}

# Upload your local public key
resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft-key-no-pass"
  public_key = file("${path.module}/minecraft-key-no-pass.pub")
}

# Security group for Minecraft port
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

# EC2 Instance
resource "aws_instance" "minecraft_server" {
  ami                    = "ami-00755a52896316cee" # Amazon Linux 2 in us-west-2
  instance_type          = "t3.small"
  key_name               = aws_key_pair.minecraft_key.key_name
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]

  provisioner "remote-exec" {
    inline = [
      "echo Hello from remote-exec!",
      "sudo yum install -y java-17-amazon-corretto", # example Minecraft dependency
      # You could add Minecraft install steps here
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/minecraft-key-no-pass")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "minecraft-server"
  }
}

output "public_ip" {
  value = aws_instance.minecraft_server.public_ip
}
