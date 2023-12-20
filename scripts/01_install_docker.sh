#!/bin/bash
# ----------------------------------------------------------------------------
# 01_install_docker.sh
# ----------------------------------------------------------------------------
# Installs docker plus compose extension.
# ----------------------------------------------------------------------------

set -eu

if [ "$AMI_ARCHITECTURE" = "arm64" ]
then
  export COMPOSE_ARCHITECTURE="aarch64"
else
  export COMPOSE_ARCHITECTURE=$AMI_ARCHITECTURE
fi

echo 'installing Docker'
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
sudo usermod -a -G docker ec2-user
sudo docker info

echo 'installing docker compose plugin'
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-$COMPOSE_ARCHITECTURE -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod a+x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version