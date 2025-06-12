# main.tf
provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "minecraft" {
  key_name   = "minecraft-key"
  public_key = file("${path.module}/minecraft-key.pub")
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

resource "aws_instance" "minecraft_server" {
  ami           = "ami-00755a52896316cee"  # Amazon Linux 2 for us-west-2
  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = aws_key_pair.minecraft.key_name

  tags = {
    Name = "minecraft-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y java-17-amazon-corretto-headless",
      "wget https://launcher.mojang.com/v1/objects/6e0a6e8efb80ed4a7ec09cc1c1bda2b4c894e3d9/server.jar -O server.jar",
      "echo 'eula=true' > eula.txt",
      "nohup java -Xmx1G -Xms1G -jar server.jar nogui &"
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
