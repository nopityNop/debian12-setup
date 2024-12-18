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

for module in "${SCRIPT_DIR}/modules/"*.sh; do
    if [ -f "$module" ]; then
        source "$module"
        check_status "Loading module $(basename "$module")"
    fi
done

echo "Starting Debian 12 setup (v${VERSION})..."
echo "----------------------------------------"

setup_wizard
check_status "Setup wizard"

validate_settings
check_status "Settings validation"

if [ -f "${SCRIPT_DIR}/config/settings.conf" ]; then
    source "${SCRIPT_DIR}/config/settings.conf"
else
    echo "Error: settings.conf not found"
    exit 1
fi

run_system_update
check_status "System update"

run_user_setup
check_status "User setup"

run_basic_tools
check_status "Basic tools installation"

run_security_setup
check_status "Security setup"

run_user_config
check_status "User configuration"

run_cleanup
check_status "System cleanup"

echo "----------------------------------------"
echo "Setup completed successfully!"
echo "You can now log in as: $SETUP_USER"
if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "SSH key authentication is configured"
else
    echo "Warning: No SSH key configured, password authentication will be required"
fi
echo "----------------------------------------"
