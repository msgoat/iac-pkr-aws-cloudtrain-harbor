#!/bin/bash
# 04_install_harbor.sh
# ----------------------------------------------------------------------------
# Installs harbor by:
# - adding a habor runtime user
# - downloading and unpacking the harbor installer
# - preparing the harbor installer
# - pulling all harbor docker images.
# The actual installation must happen during EC2 boot using user data scripts.
# ----------------------------------------------------------------------------
set -ue

export HARBOR_HOME=/opt/harbor
export HARBOR_BIN_HOME=$HARBOR_HOME/bin
export HARBOR_DATA_HOME=$HARBOR_HOME/data
export HARBOR_DOWNLOAD_URL=https://github.com/goharbor/harbor/releases/download
export HARBOR_PACKAGE_NAME=harbor-online-installer-$HARBOR_VERSION.tgz
export HARBOR_PACKAGE_URL=$HARBOR_DOWNLOAD_URL/$HARBOR_VERSION/$HARBOR_PACKAGE_NAME
export HARBOR_KEY_NAME=$HARBOR_PACKAGE_NAME.asc
export HARBOR_KEY_URL=$HARBOR_DOWNLOAD_URL/$HARBOR_VERSION/$HARBOR_KEY_NAME

echo "Create harbor runtime user"
sudo adduser harbor --system

echo "Create all required folders"
sudo mkdir -p $HARBOR_BIN_HOME
sudo mkdir -p $HARBOR_DATA_HOME
sudo chown -R ec2-user:ec2-user $HARBOR_HOME

echo "Download Harbor package using Harbor version $HARBOR_VERSION"
curl -L -o $HARBOR_BIN_HOME/$HARBOR_PACKAGE_NAME $HARBOR_PACKAGE_URL

echo "Verify genuinity of Harbor package"
curl -L -o $HARBOR_BIN_HOME/$HARBOR_KEY_NAME $HARBOR_KEY_URL
sudo gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 644FF454C0B4115C
sudo gpg -v --keyserver hkps://keyserver.ubuntu.com --verify $HARBOR_BIN_HOME/$HARBOR_KEY_NAME

echo "Unpack Harbor package"
tar xzf $HARBOR_BIN_HOME/$HARBOR_PACKAGE_NAME -C $HARBOR_BIN_HOME --strip-components=1

echo "Delete Harbor package"
rm $HARBOR_BIN_HOME/*.tgz
rm $HARBOR_BIN_HOME/*.asc

echo "Pre-start Harbor installation by preparing the compose file and pulling all images"
sudo rm -f $HARBOR_BIN_HOME/harbor.yml
export HARBOR_HOST_NAME=docker.cloudtrain.aws.msgoat.eu
export HARBOR_EXTERNAL_URL=https://$HARBOR_HOST_NAME
export HARBOR_DATA_VOLUME=$HARBOR_DATA_HOME
export HARBOR_LOG_LOCAL_LOCATION=$HARBOR_DATA_VOLUME/log/harbor
export HARBOR_POSTGRES_HOST=postgres
export HARBOR_POSTGRES_PORT=5432
export HARBOR_POSTGRES_NAME=registry
export HARBOR_POSTGRES_USERNAME=postgres
export HARBOR_POSTGRES_PASSWORD=s3cr3t
export HARBOR_STORAGE_S3_ACCESS_KEY=aws_access_key
export HARBOR_STORAGE_S3_SECRET_KEY=aws_secret_key
export HARBOR_STORAGE_S3_REGION=eu-central-1
export HARBOR_STORAGE_S3_BUCKET_NAME=harbor
envsubst </tmp/harbor.yml >$HARBOR_BIN_HOME/harbor.yml
chown ec2-user:ec2-user $HARBOR_BIN_HOME/harbor.yml
cd $HARBOR_BIN_HOME
sudo ./prepare --with-trivy
sudo docker compose -f $HARBOR_BIN_HOME/docker-compose.yml pull

echo "Allow harbor user to access all harbor folders"
sudo chown -R harbor $HARBOR_HOME

