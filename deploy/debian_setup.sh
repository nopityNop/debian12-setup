#!/bin/bash

# Debian 12 System Setup Script

set -e

VERSION="1.0.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "/etc/debian_version" ]; then
    echo "Error: This script must be run on Debian"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root"
    exit 1
fi

check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# Source all modules
source "$SCRIPT_DIR/modules/setup_wizard.sh"
source "$SCRIPT_DIR/modules/system_update.sh"
source "$SCRIPT_DIR/modules/user_setup.sh"
source "$SCRIPT_DIR/modules/security_setup.sh"
source "$SCRIPT_DIR/modules/basic_tools.sh"

echo "Starting Debian 12 setup (v${VERSION})..."
echo "----------------------------------------"

# Run setup steps
run_setup_wizard || exit 1
run_system_update || exit 1
install_basic_tools || exit 1
setup_user || exit 1
setup_security || exit 1

if [ -f "${SCRIPT_DIR}/config/settings.conf" ]; then
    source "${SCRIPT_DIR}/config/settings.conf"
else
    echo "Error: settings.conf not found"
    exit 1
fi

echo "----------------------------------------"
echo "Setup completed successfully!"
echo "You can now log in as: $SETUP_USER"
if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "SSH key authentication is configured"
else
    echo "Warning: No SSH key configured, password authentication will be required"
fi
echo "----------------------------------------"
