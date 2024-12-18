# Debian 12 Setup Script

Automated setup script for Debian 12 that:
- Updates system packages
- Creates a sudo user with SSH key
- Configures SSH hardening
- Sets up UFW firewall with security rules
- Installs and configures unattended-upgrades

## Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/nopityNop/debian12-setup/main/install.sh | sudo bash
```

## Features

- Interactive setup wizard
- System update and upgrade
- User creation with sudo access
- SSH key configuration
- SSH hardening
- UFW firewall setup
- Automatic security updates
- INVALID packet blocking

## Requirements

- Debian 12 (Bookworm)
- Root access
- Internet connection
