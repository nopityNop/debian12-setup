#!/bin/bash

install_basic_tools() {
    echo "=== Installing Basic Tools ==="
    
    # Read tools from settings.conf
    source "$(dirname "$0")/../config/settings.conf"
    
    if [ -z "$BASIC_TOOLS" ]; then
        echo "Error: BASIC_TOOLS not defined in settings.conf"
        return 1
    }
    
    # Update package list
    apt-get update || {
        echo "Error: Failed to update package list"
        return 1
    }
    
    # Install each tool
    for tool in $BASIC_TOOLS; do
        echo "Installing $tool..."
        apt-get install -y "$tool" || {
            echo "Error: Failed to install $tool"
            return 1
        }
    done
    
    echo "Basic tools installation complete"
    return 0
}
