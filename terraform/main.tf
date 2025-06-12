provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft-key-no-pass"
  public_key = file("${path.module}/minecraft-key-no-pass.pub")
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_sg"
  description = "Allow Minecraft port and SSH for provisioning"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Or use your IP for security: ["<your_ip>/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft_server" {
  ami                         = "ami-00755a52896316cee" # Amazon Linux 2, verified
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.minecraft_key.key_name
  vpc_security_group_ids      = [aws_security_group.minecraft_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "minecraft-server"
  }

  provisioner "file" {
    source      = "install_unix.sh"
    destination = "/home/ec2-user/install_unix.sh"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/minecraft-key-no-pass")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 5",
      "ls -l /home/ec2-user",
      "chmod +x /home/ec2-user/install_unix.sh",
      "sudo /home/ec2-user/install_unix.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/minecraft-key-no-pass")
      host        = self.public_ip
    }
  }
}

output "public_ip" {
  value = aws_instance.minecraft_server.public_ip
}