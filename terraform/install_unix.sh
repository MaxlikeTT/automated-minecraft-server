#!/bin/bash

# Install Java
sudo yum update -y
sudo amazon-linux-extras enable corretto8
sudo yum install -y java-1.8.0-amazon-corretto

# Create Minecraft server directory
mkdir -p /home/ec2-user/minecraft
cd /home/ec2-user/minecraft

# Download Minecraft server .jar
wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar -O server.jar

# Accept EULA
echo "eula=true" > eula.txt

# Create systemd service
sudo tee /etc/systemd/system/minecraft.service > /dev/null <<EOF
[Unit]
Description=Minecraft Server
After=network.target

[Service]
WorkingDirectory=/home/ec2-user/minecraft
ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
User=ec2-user
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the Minecraft service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable minecraft
sudo systemctl start minecraft
