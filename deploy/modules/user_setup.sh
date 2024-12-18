#!/bin/bash

run_user_setup() {
    echo "=== User Setup Phase ==="
    
    echo "Creating user: $SETUP_USER"
    useradd -m -s /bin/bash "$SETUP_USER"
    check_status "User creation"
    
    echo "Configuring sudo access..."
    usermod -aG sudo "$SETUP_USER"
    check_status "Adding user to sudo group"
    
    echo "Verifying sudo access..."
    if getent group sudo | grep -q "\b${SETUP_USER}\b"; then
        echo "✓ User $SETUP_USER is in sudo group"
    else
        echo "Error: Failed to add $SETUP_USER to sudo group"
        exit 1
    fi
    
    echo "Setting password for $SETUP_USER"
    echo "Please enter the password for $SETUP_USER:"
    passwd "$SETUP_USER"
    check_status "Password setup"
    
    echo "Setting up SSH directory..."
    USER_HOME="/home/$SETUP_USER"
    SSH_DIR="$USER_HOME/.ssh"
    
    mkdir -p "$SSH_DIR"
    check_status "Creating SSH directory"
    
    chown -R "$SETUP_USER:$SETUP_USER" "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    
    if [ -n "$SSH_PUBLIC_KEY" ]; then
        echo "Adding SSH public key..."
        echo "$SSH_PUBLIC_KEY" > "$SSH_DIR/authorized_keys"
        chmod 600 "$SSH_DIR/authorized_keys"
        chown "$SETUP_USER:$SETUP_USER" "$SSH_DIR/authorized_keys"
        check_status "Adding SSH key"
    else
        echo "Warning: No SSH key provided, password authentication will be required"
    fi
    
    echo "User setup completed for: $SETUP_USER"
    echo "Sudo access verification:"
    echo "- User is in sudo group: $(groups $SETUP_USER)"
    echo "- Sudo privileges:"
    sudo -l -U $SETUP_USER
    echo
}
