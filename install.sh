#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root"
    exit 1
fi

if [ ! -f "/etc/debian_version" ]; then
    echo "Error: This script must be run on Debian"
    exit 1
fi

apt update
apt install -y curl unzip

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT
cd "$TEMP_DIR" || exit 1

echo "Downloading setup scripts..."
curl -L https://github.com/nopityNop/debian12-setup/archive/refs/heads/main.zip -o debian12-setup.zip
unzip debian12-setup.zip
cd debian12-setup-main/deploy || exit 1

chmod +x debian_setup.sh
chmod +x modules/*.sh

./debian_setup.sh
