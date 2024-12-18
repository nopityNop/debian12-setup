#!/bin/bash

run_system_update() {
    echo "=== System Update Phase ==="
    
    echo "Updating system packages..."
    apt update && apt upgrade -y
    check_status "System update and upgrade"
    
    echo "Installing and configuring unattended-upgrades..."
    apt install -y unattended-upgrades apt-listchanges
    check_status "Installing unattended-upgrades"
    
    # Configure unattended-upgrades for security updates
    echo 'Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,codename=${distro_codename},label=Debian-Security";
    };
    Unattended-Upgrade::AutoFixInterruptedDpkg "true";
    Unattended-Upgrade::MinimalSteps "true";
    Unattended-Upgrade::Remove-Unused-Dependencies "true";' > /etc/apt/apt.conf.d/50unattended-upgrades
    
    # Enable automatic updates
    echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";' > /etc/apt/apt.conf.d/20auto-upgrades
    
    check_status "Configuring unattended-upgrades"
    
    # Enable the unattended-upgrades service
    systemctl enable unattended-upgrades
    systemctl start unattended-upgrades
    check_status "Starting unattended-upgrades service"
    
    echo "System update phase completed"
    echo
}
