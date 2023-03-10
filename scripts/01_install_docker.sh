#!/bin/bash

set -eu

if [ "$AMI_ARCHITECTURE" = "arm64" ]
then
  export COMPOSE_ARCHITECTURE="aarch64"
else
  export COMPOSE_ARCHITECTURE=$AMI_ARCHITECTURE
fi

echo 'installing Docker from Amazon Linux Extras packages'
sudo amazon-linux-extras install docker
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
sudo usermod -a -G docker ec2-user
sudo docker info

echo 'installing docker compose plugin'
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-$COMPOSE_ARCHITECTURE -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod a+x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version