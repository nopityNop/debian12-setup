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
apt install -y git

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || exit 1

echo "Downloading setup scripts..."
git clone https://github.com/YOUR_USERNAME/debian-setup.git
cd debian-setup || exit 1

chmod +x debian_setup.sh
chmod +x modules/*.sh

./debian_setup.sh

cd /
rm -rf "$TEMP_DIR"
