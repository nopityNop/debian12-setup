#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root"
    exit 1
fi

# Check if running on Debian
if [ ! -f "/etc/debian_version" ]; then
    echo "Error: This script must be run on Debian"
    exit 1
fi

# Install required packages
apt update
apt install -y git

# Set up temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || exit 1

# Clone the repository
echo "Downloading setup scripts..."
git clone --depth=1 https://github.com/nopityNop/debian12-setup.git
cd debian12-setup/deploy || exit 1

# Make scripts executable
chmod +x debian_setup.sh
chmod +x modules/*.sh

# Run the setup
./debian_setup.sh

# Cleanup
cd /
rm -rf "$TEMP_DIR"
