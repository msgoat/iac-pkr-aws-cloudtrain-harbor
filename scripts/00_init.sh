#!/bin/bash

echo 'updating installed packages'
sudo yum update -y

echo 'installing missing packages'
sudo yum install -y gettext