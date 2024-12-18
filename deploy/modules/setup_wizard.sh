#!/bin/bash

setup_wizard() {
    echo "=== Debian Setup Wizard ==="
    echo "Please provide the following information:"
    echo

    while true; do
        read -p "Enter username to create: " USERNAME
        if [[ -z "$USERNAME" ]]; then
            echo "Username cannot be empty"
            continue
        fi
        if [[ ! "$USERNAME" =~ ^[a-z][-a-z0-9]*$ ]]; then
            echo "Invalid username format. Username must:"
            echo "- Start with a lowercase letter"
            echo "- Contain only lowercase letters, numbers, and hyphens"
            continue
        fi
        break
    done
    echo

    echo "SSH Public Key setup:"
    echo "1. Enter path to existing public key"
    echo "2. Paste public key content"
    echo "3. Skip (not recommended)"
    read -p "Choose option [1]: " SSH_OPTION
    SSH_OPTION=${SSH_OPTION:-"1"}

    case $SSH_OPTION in
        1)
            read -p "Enter path to public key file: " SSH_KEY_PATH
            while [[ ! -f "$SSH_KEY_PATH" ]]; do
                echo "File not found!"
                read -p "Enter path to public key file: " SSH_KEY_PATH
            done
            SSH_KEY=$(cat "$SSH_KEY_PATH")
            ;;
        2)
            echo "Paste your public key (ssh-rsa ...) and press Enter:"
            read SSH_KEY
            while [[ ! "$SSH_KEY" =~ ^ssh-rsa[[:space:]] ]]; do
                echo "Invalid SSH key format! Should start with 'ssh-rsa'"
                read SSH_KEY
            done
            ;;
        3)
            echo "Warning: Skipping SSH key setup is not recommended for security"
            SSH_KEY=""
            ;;
        *)
            echo "Invalid option, defaulting to skip"
            SSH_KEY=""
            ;;
    esac

    cat > "${SCRIPT_DIR}/config/settings.conf" << EOL
# Debian 12 Setup Configuration

LOCALE="en_US.UTF-8"

# User Settings
SETUP_USER="$USERNAME"
SSH_PUBLIC_KEY="$SSH_KEY"

# Security Settings
ENABLE_UFW=true
ENABLE_SSH=true
SSH_PORT=22
DISABLE_ROOT_SSH=true
DISABLE_PASSWORD_AUTH=true

BASIC_TOOLS="vim htop tmux git curl wget net-tools ufw unattended-upgrades python3 python3-pip perl"

# Update Settings
ENABLE_AUTOMATIC_UPDATES=true
UPDATE_LEVEL="security"
EOL

    echo
    echo "Configuration saved to ${SCRIPT_DIR}/config/settings.conf"
    echo "Review the settings above and press Enter to continue or Ctrl+C to abort"
    read
}

validate_settings() {
    if [[ -n "$SSH_PUBLIC_KEY" && ! "$SSH_PUBLIC_KEY" =~ ^ssh-rsa[[:space:]] ]]; then
        echo "Error: Invalid SSH key format"
        exit 1
    fi
}
