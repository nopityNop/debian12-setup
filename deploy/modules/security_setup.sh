#!/bin/bash

run_security_setup() {
    echo "=== Security Setup Phase ==="
    
    echo "Hardening SSH configuration..."
    
    SSHD_CONFIG="/etc/ssh/sshd_config"
    
    sed -i '/^#*PasswordAuthentication/c\PasswordAuthentication no' $SSHD_CONFIG
    check_status "Disabling password authentication"
    
    sed -i '/^#*UsePAM/c\UsePAM no' $SSHD_CONFIG
    check_status "Disabling PAM"
    
    sed -i '/^#*PermitRootLogin/c\PermitRootLogin no' $SSHD_CONFIG
    check_status "Disabling root login"
    
    if grep -q '^ChallengeResponseAuthentication' $SSHD_CONFIG; then
        sed -i '/^#*ChallengeResponseAuthentication/c\ChallengeResponseAuthentication no' $SSHD_CONFIG
    else
        echo 'ChallengeResponseAuthentication no' >> $SSHD_CONFIG
    fi
    check_status "Disabling challenge-response authentication"
    
    echo "Restarting SSH service..."
    systemctl restart sshd
    check_status "SSH service restart"
    
    echo "Configuring UFW firewall..."
    
    apt install -y ufw
    check_status "Installing UFW"
    
    ufw disable
    check_status "Disabling UFW"
    
    ufw reset
    check_status "Resetting UFW"
    
    echo "Configuring UFW rules..."
    
    ufw limit 22/tcp
    check_status "Setting SSH rate limiting"
    
    echo "Configuring INVALID packet blocking..."
    
    sed -i '/# drop INVALID packets/,/--ctstate INVALID -j DROP/!b;:a;n;/^$/!ba;r /dev/stdin' /etc/ufw/before.rules << EOF
# Added rules for new connections without SYN flag
-A ufw-before-input -p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ufw-logging-deny
-A ufw-before-input -p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j DROP
EOF
    check_status "Configuring IPv4 INVALID packet rules"
    
    sed -i '/# drop INVALID packets/,/--ctstate INVALID -j DROP/!b;:a;n;/^$/!ba;r /dev/stdin' /etc/ufw/before6.rules << EOF
# Added rules for new IPv6 connections without SYN flag
-A ufw6-before-input -p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ufw6-logging-deny
-A ufw6-before-input -p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j DROP
EOF
    check_status "Configuring IPv6 INVALID packet rules"
    
    echo "Enabling UFW..."
    echo "y" | ufw enable
    check_status "Enabling UFW"
    
    ufw status verbose
    
    echo "Security setup completed"
    echo
}
