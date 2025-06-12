provider "aws" {
  region = "us-west-2"
}

# Key Pair for SSH (only used by Terraform for remote-exec)
resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft-key"
  public_key = file("${path.module}/minecraft-key.pub")
}

# Security Group to allow Minecraft traffic
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
  ami                         = "ami-00755a52896316cee"  # Amazon Linux 2
  instance_type               = "t3.small"
  vpc_security_group_ids      = [aws_security_group.minecraft_sg.id]
  key_name                    = aws_key_pair.minecraft_key.key_name

  tags = {
    Name = "minecraft-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y java-1.8.0-openjdk",
      "sudo mkdir -p /opt/minecraft",
      "cd /opt/minecraft",
      "sudo wget https://launcher.mojang.com/v1/objects/f7b6314d976fc4a6fd9e1fcae3322f252b2fca89/server.jar",
      "echo 'eula=true' | sudo tee /opt/minecraft/eula.txt",
      "nohup sudo java -Xmx1024M -Xms1024M -jar /opt/minecraft/server.jar nogui &"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/minecraft-key")
      host        = self.public_ip
    }
  }
}

output "public_ip" {
  value = aws_instance.minecraft_server.public_ip
}
