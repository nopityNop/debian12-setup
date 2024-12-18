#!/bin/bash

setup_wizard() {
    echo "=== Debian Setup Wizard ==="
    echo "Please provide the following information:"
    echo

    echo "Available timezones:"
    timedatectl list-timezones | grep "America/" | sort
    echo
    read -p "Enter timezone [America/Los_Angeles]: " USER_TIMEZONE
    TIMEZONE=${USER_TIMEZONE:-"America/Los_Angeles"}
    echo "Setting timezone to: $TIMEZONE"
    echo

    read -p "Enter hostname [debian-server]: " USER_HOSTNAME
    HOSTNAME=${USER_HOSTNAME:-"debian-server"}
    echo "Setting hostname to: $HOSTNAME"
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

# System Settings
TIMEZONE="$TIMEZONE"
HOSTNAME="$HOSTNAME"
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

# Package Settings
EXTRA_PACKAGES=(
    "vim"
    "curl"
    "wget"
    "htop"
    "tmux"
    "git"
    "zip"
    "unzip"
    "net-tools"
    "sudo"
)

# Update Settings
ENABLE_AUTOMATIC_UPDATES=true
UPDATE_LEVEL="security"  # Options: security, all
EOL

    echo
    echo "Configuration saved to ${SCRIPT_DIR}/config/settings.conf"
    echo "Review the settings above and press Enter to continue or Ctrl+C to abort"
    read
}

validate_settings() {
    if ! timedatectl list-timezones | grep -q "^${TIMEZONE}$"; then
        echo "Error: Invalid timezone: ${TIMEZONE}"
        exit 1
    fi

    if [[ ! "$HOSTNAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-])*[a-zA-Z0-9]$ ]]; then
        echo "Error: Invalid hostname format: ${HOSTNAME}"
        exit 1
    fi

    if [[ -n "$SSH_PUBLIC_KEY" && ! "$SSH_PUBLIC_KEY" =~ ^ssh-rsa[[:space:]] ]]; then
        echo "Error: Invalid SSH key format"
        exit 1
    fi
}
