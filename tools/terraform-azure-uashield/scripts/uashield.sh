#!/bin/sh

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget

wget -O - https://get.docker.com/ | bash

sudo systemctl enable docker.service
sudo systemctl start docker.service

mkdir -p /home/adminuser/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o /home/adminuser/.docker/cli-plugins/docker-compose
chmod +x /home/adminuser/.docker/cli-plugins/docker-compose
sudo chown $USER /var/run/docker.sock

sudo echo "
version: \"3.3\"
services:
  worker:
    image: ghcr.io/opengs/uashield:latest
    restart: always
    command:
      - \"7500\"
      - \"true\"" >> /home/docker-compose.yaml

sudo apt install -y docker-compose

cd /home/

sudo docker-compose pull && sudo docker-compose up -d --scale worker=$(grep -c ^processor /proc/cpuinfo)

sudo echo "*/30 * * * * cd /home/ && sudo docker-compose down -t 1 && sudo docker-compose pull && sudo docker-compose up -d --scale worker=$(grep -c ^processor /proc/cpuinfo)" >> /home/cronjob
crontab /home/cronjob