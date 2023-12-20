#!/bin/bash

echo 'updating installed packages'
sudo dnf update -y

echo 'installing missing packages'
sudo dnf install -y gettext