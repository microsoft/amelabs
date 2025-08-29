#!/bin/bash
# scripts/install_ama_forwarder.sh

set -euo pipefail
IFS=$'\n\t'

# Update only Microsoft Azure repos
sudo yum update -y --disablerepo='*' --enablerepo='*microsoft-azure*'

# Open syslog ports in the firewall
echo "Configuring firewall..."
sudo firewall-cmd --zone=public --add-port=514/tcp --permanent
sudo firewall-cmd --zone=public --add-port=514/udp --permanent
sudo firewall-cmd --reload

# Install required packages
echo "Installing dependencies..."
sudo yum install -y python3 curl wget

# Download the installer
echo "Downloading AMA Forwarder installer..."
sudo wget -O Forwarder_AMA_installer.py https://raw.githubusercontent.com/Azure/Azure-Sentinel/master/DataConnectors/Syslog/Forwarder_AMA_installer.py

# Run the installer
echo "Running installer..."
sudo python3 Forwarder_AMA_installer.py

echo "Installation completed successfully."