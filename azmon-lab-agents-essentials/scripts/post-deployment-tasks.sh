#!/bin/bash

set -e

# Color codes for better user experience
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if required parameters are provided
if [ $# -ne 7 ]; then
    echo -e "${RED}Usage: $0 <RESOURCE_GROUP> <REDHAT_VM_NAME> <UBUNTU_VM_NAME> <WINDOWS_VM_NAME> <VMSS_NAME> <REDHAT_PRIVATE_IP> <UTC_TIME> ${NC}"
    echo ""
    echo -e "${CYAN}Parameters:${NC}"
    echo -e "${CYAN}  RESOURCE_GROUP    - Name of the Azure resource group${NC}"
    echo -e "${CYAN}  REDHAT_VM_NAME    - Name of the Red Hat virtual machine${NC}"
    echo -e "${CYAN}  UBUNTU_VM_NAME    - Name of the Ubuntu virtual machine${NC}"
    echo -e "${CYAN}  WINDOWS_VM_NAME   - Name of the Windows virtual machine${NC}"
    echo -e "${CYAN}  VMSS_NAME         - Name of the Windows virtual machine scale set${NC}"
    echo -e "${CYAN}  REDHAT_PRIVATE_IP - Private IP address of the Red Hat VM${NC}"
    exit 1
fi

# Assign input parameters to variables
RESOURCE_GROUP="$1"
REDHAT_VM_NAME="$2"
UBUNTU_VM_NAME="$3"
WINDOWS_VM_NAME="$4"
VMSS_NAME="$5"
REDHAT_PRIVATE_IP="$6"
USER_TIMEZONE="$7"

# Display received parameters
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}Starting End Tasks Configuration${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}Resource Group: ${YELLOW}$RESOURCE_GROUP${NC}"
echo -e "${CYAN}Red Hat VM: ${YELLOW}$REDHAT_VM_NAME${NC}"
echo -e "${CYAN}Ubuntu VM: ${YELLOW}$UBUNTU_VM_NAME${NC}"
echo -e "${CYAN}Windows VM: ${YELLOW}$WINDOWS_VM_NAME${NC}"
echo -e "${CYAN}VMSS: ${YELLOW}$VMSS_NAME${NC}"
echo -e "${CYAN}Red Hat Private IP: ${YELLOW}$REDHAT_PRIVATE_IP${NC}"
echo -e "${CYAN}User Timezone: ${YELLOW}$USER_TIMEZONE${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""


# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Execute the Sentinel AMA forwarder install script
echo -e "${CYAN}🔧 Installing AMA Forwarder on Red Hat VM: ${YELLOW}$REDHAT_VM_NAME${NC}"

az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$REDHAT_VM_NAME" \
  --command-id RunShellScript \
  --scripts "$(cat "$SCRIPT_DIR/deploy_ama_forwarder.sh")"


# Deploy the CEF simulator script on Ubuntu machine
echo -e "${CYAN}🔧 Installing CEF Simulator on Ubuntu VM: ${YELLOW}$UBUNTU_VM_NAME${NC}"

az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$UBUNTU_VM_NAME" \
  --command-id RunShellScript \
  --scripts "$(cat "$SCRIPT_DIR/deploy_cef_simulator.sh")" \
  --parameters "redhatip_input=$REDHAT_PRIVATE_IP"


# Use the provided UTC time directly
# User UTC time is already calculated in init-lab.sh based on their local timezone offset
echo -e "${CYAN}🕐 Using UTC time for auto-shutdown: ${YELLOW}$USER_TIMEZONE${NC}"
echo -e "${CYAN}This corresponds to 7:00 PM in your local timezone${NC}"

SHUTDOWN_TIME="$USER_TIMEZONE"  # UTC time in HHMM format (e.g., 1900, 0000, 1200)

echo -e "${CYAN}Configured shutdown time (UTC): ${YELLOW}$SHUTDOWN_TIME${NC}"

# Configure auto-shutdown for all VMs
echo -e "${CYAN}🔧 Configuring auto-shutdown for all VMs ...${NC}"

# Function to configure auto-shutdown for a VM
configure_vm_autoshutdown() {
  local vm_name=$1
  local resource_group=$2
  local shutdown_time=$3
  
  echo -e "  ${CYAN}📝 Configuring auto-shutdown for VM: ${YELLOW}$vm_name${NC}"
  
  # Enable auto-shutdown (no email notifications)
  az vm auto-shutdown \
    --resource-group "$resource_group" \
    --name "$vm_name" \
    --time "$shutdown_time"
  
  if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✅ Auto-shutdown configured successfully for VM: ${YELLOW}$vm_name${NC}"
  else
    echo -e "  ${RED}❌ Failed to configure auto-shutdown for VM: ${YELLOW}$vm_name${NC}"
  fi
}

# Configure auto-shutdown for all VMs
configure_vm_autoshutdown "$UBUNTU_VM_NAME" "$RESOURCE_GROUP" "$SHUTDOWN_TIME"
configure_vm_autoshutdown "$WINDOWS_VM_NAME" "$RESOURCE_GROUP" "$SHUTDOWN_TIME"
configure_vm_autoshutdown "$REDHAT_VM_NAME" "$RESOURCE_GROUP" "$SHUTDOWN_TIME"


echo -e "${GREEN}🎉 Auto-shutdown configuration completed!${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}📋 Summary:${NC}"
echo -e "${CYAN}  - Shutdown time (UTC): ${YELLOW}$SHUTDOWN_TIME${CYAN} (corresponds to 7:00 PM in your local timezone)${NC}"
echo -e "${CYAN}  - VMs configured: ${YELLOW}$UBUNTU_VM_NAME, $WINDOWS_VM_NAME, $REDHAT_VM_NAME${NC}"
echo -e "${CYAN}  - All VMs will automatically shutdown at the configured UTC time${NC}"
echo -e "${BLUE}========================================${NC}"