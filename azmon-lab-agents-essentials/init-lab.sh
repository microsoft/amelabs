#!/bin/bash

# -----------------------------------------------------------------------------
# NOTE FOR USERS:
#
# This script collects Azure input values (e.g., resource group, region)
# to generate a local terraform.tfvars file for lab automation.
#
# ❗ No data is ever sent or uploaded back to GitHub or anywhere else.
# ❗ No telemetry, logging, or push occurs.
# ✅ All data remains local to your current shell session.
# -----------------------------------------------------------------------------


set -e

# Color codes for better user experience
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Clone the repo (skip if already cloned)
if [ ! -d "amelabs" ]; then
  echo -e "${CYAN}Cloning amelabs repository...${NC}"
  git clone https://github.com/microsoft/amelabs.git
fi


# -------------------------------
# Functions
# -------------------------------

# Register Azure resource provider if not yet registered
register_provider() {
  local ns=$1
  local status=$(az provider show --namespace "$ns" --query "registrationState" -o tsv 2>/dev/null || echo "NotRegistered")

  if [ "$status" != "Registered" ]; then
    echo -e "${CYAN}Registering provider: ${YELLOW}$ns${CYAN}...${NC}"
    az provider register --namespace "$ns"
    until [ "$(az provider show --namespace "$ns" --query "registrationState" -o tsv)" == "Registered" ]; do
      echo -e "${CYAN}Waiting for ${YELLOW}$ns${CYAN} registration...${NC}"
      sleep 5
    done
    echo -e "${GREEN}Provider ${YELLOW}$ns${GREEN} registered successfully.${NC}"
  else
    echo -e "${GREEN}Provider ${YELLOW}$ns${GREEN} already registered.${NC}"
  fi
}

# Prompt user input with validation
prompt_input() {
  local prompt_msg=$1
  local var_name=$2
  local current_value="${!var_name}"
  
  if [ -n "$current_value" ]; then
    read -rp "$(echo -e "${CYAN}$prompt_msg ${YELLOW}[$current_value]${CYAN}: ${NC}")" input
    if [ -n "$input" ]; then
      eval $var_name="$input"
    fi
  else
    while [ -z "${!var_name}" ]; do
      read -rp "$(echo -e "${CYAN}$prompt_msg: ${NC}")" $var_name
    done
  fi
}

# -------------------------------
# Main Script
# -------------------------------

echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}Azure Monitor Labs Initialization${NC}"
echo -e "${BLUE}========================================${NC}"

# Set default values
RESOURCE_GROUP="rg-azmon-lab"
LOCATION="uksouth"
WORKSPACE_NAME="azmon-workspace"
AKS_CLUSTER="aks-azmon"
MANAGED_GRAFANA="managed-gf"
PROM_NAME="managed-pm"

# Register necessary Azure providers
echo -e "${CYAN}Registering Azure providers...${NC}"
for ns in Microsoft.Insights Microsoft.OperationalInsights Microsoft.Monitor Microsoft.Security Microsoft.Compute Microsoft.SecurityInsights Microsoft.Dashboard; do
  register_provider "$ns"
done

echo ""
echo -e "${CYAN}🔧 Configuration Setup${NC}"
echo -e "${CYAN}Please provide the following configuration values:${NC}"
echo ""

# Prompt for deployment parameters
prompt_input "Enter the name for the Azure Resource Group" RESOURCE_GROUP
prompt_input "Enter the Azure location supported by Sentinel (e.g., westeurope)" LOCATION
prompt_input "Enter the name for the Log Analytics Workspace" WORKSPACE_NAME
prompt_input "Enter the name for the AKS cluster" AKS_CLUSTER
prompt_input "Enter the name for the Managed Grafana" MANAGED_GRAFANA
prompt_input "Enter the name for the Azure Monitor Workspace(Managed Prometheus)" PROM_NAME

# Prompt for timezone for auto-shutdown configuration
echo ""
echo -e "${CYAN}🕐 Auto-shutdown Configuration${NC}"
echo -e "${CYAN}Auto-shutdown will be configured for all VMs and VMSS at 7:00 PM in your timezone.${NC}"

# Default shutdown time
local_time="19:00"

# Prompt user for UTC offset
read -p "$(echo -e "${CYAN}Enter your time zone as UTC offset (e.g., UTC, UTC+1, UTC-5): ${NC}")" tz_input

# Convert to uppercase for case-insensitive matching
tz_input_upper=$(echo "$tz_input" | tr '[:lower:]' '[:upper:]')

# Parse offset
if [[ "$tz_input_upper" == "UTC" ]]; then
  offset="+0"
elif [[ "$tz_input_upper" =~ ^UTC([+-][0-9]{1,2})$ ]]; then
  offset="${BASH_REMATCH[1]}"
else
  echo -e "${RED}Invalid UTC offset format. Please use format like UTC, UTC+1, UTC-5${NC}"
  exit 1
fi
# Get today's date in YYYY-MM-DD
today=$(date +%F)

# Combine date and time
datetime="$today $local_time"

# Convert to UTC using the offset
USER_TIMEZONE=$(date -u -d "$datetime $offset" +%H%M 2>/dev/null)

if [[ -z "$USER_TIMEZONE" ]]; then
  echo -e "${YELLOW}Failed to convert time. Using fallback 1900 UTC.${NC}"
  USER_TIMEZONE="1900"
fi

# Prompt for common admin password
echo ""
echo -e "${CYAN}🔐 Security Configuration${NC}"
echo -e "${CYAN}All VMs and VMSS will use 'azureuser' as the common username.${NC}"
echo -e "${CYAN}Please provide a secure password for all resources:${NC}"
echo -e "${YELLOW}Password requirements: 12+ characters, uppercase, lowercase, digit, special character${NC}"

while true; do
  read -s -p "$(echo -e "${CYAN}Enter admin password: ${NC}")" ADMIN_PASSWORD
  echo ""
  read -s -p "$(echo -e "${CYAN}Confirm admin password: ${NC}")" ADMIN_PASSWORD_CONFIRM
  echo ""
  
  if [ "$ADMIN_PASSWORD" != "$ADMIN_PASSWORD_CONFIRM" ]; then
    echo -e "${RED}Passwords do not match. Please try again.${NC}"
    continue
  fi
  
  # Basic password validation
  if [[ ${#ADMIN_PASSWORD} -lt 12 ]]; then
    echo -e "${RED}Password must be at least 12 characters long.${NC}"
    continue
  fi
  
  if [[ ! "$ADMIN_PASSWORD" =~ [A-Z] ]] || [[ ! "$ADMIN_PASSWORD" =~ [a-z] ]] || [[ ! "$ADMIN_PASSWORD" =~ [0-9] ]] || [[ ! "$ADMIN_PASSWORD" =~ [^A-Za-z0-9] ]]; then
    echo -e "${RED}Password must contain uppercase, lowercase, digit, and special character.${NC}"
    continue
  fi
  
  echo -e "${GREEN}✅ Password accepted${NC}"
  break
done


# Fetch Azure subscription ID
echo -e "${CYAN}Retrieving Azure subscription information...${NC}"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
if [ -z "$SUBSCRIPTION_ID" ]; then
  echo -e "${RED}ERROR: Could not retrieve Azure subscription ID${NC}"
  exit 1
fi

# Write user input to tfvars file
echo -e "${CYAN}Creating configuration file...${NC}"
ENV_DIR="amelabs/azmon-lab-agents-essentials/terraform/environments/default"
mkdir -p "$ENV_DIR"

cat > "$ENV_DIR/terraform.tfvars" <<EOF
# Core Configuration
resource_group_name = "$RESOURCE_GROUP"
location            = "$LOCATION"
workspace_name      = "$WORKSPACE_NAME"
subscription_id     = "$SUBSCRIPTION_ID"
user_timezone       = "$USER_TIMEZONE"
aks_name            = "$AKS_CLUSTER"
grafana_name        = "$MANAGED_GRAFANA"
prom_name           = "$PROM_NAME"

# Network Configuration
subnet_name = "vmss_subnet"

# Common Admin Credentials (used for all VMs and VMSS)
admin_username = "azureuser"

# VMSS Configuration
vmss_name      = "vmss-win"

# Ubuntu VM Configuration
ubuntu_vm_name         = "vm-ubuntu-lab"
ubuntu_vm_size         = "Standard_B2s"

# Windows VM Configuration
windows_vm_name         = "vm-windows-lab"
windows_vm_size         = "Standard_B2s"

# Red Hat VM Configuration
redhat_vm_name         = "vm-redhat-lab"
redhat_vm_size         = "Standard_B2s"

# Automation Configuration
automation_account_name = "aa-azmon-autoshutdown"
EOF

# Export PWD to environment variable for use in scripts
export TF_VAR_admin_password="$ADMIN_PASSWORD"

# Display the created tfvars file
echo ""
echo -e "${GREEN}✅ terraform.tfvars has been created locally in: ${YELLOW}$ENV_DIR${NC}"
echo -e "${CYAN}🔒 This file is private to your environment and NOT uploaded to GitHub.${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}📋 Deployment Summary:${NC}"
echo -e "${CYAN}  - Resource Group: ${YELLOW}$RESOURCE_GROUP${NC}"
echo -e "${CYAN}  - Location: ${YELLOW}$LOCATION${NC}"  
echo -e "${CYAN}  - Log Analytics Workspace: ${YELLOW}$WORKSPACE_NAME${NC}"
echo -e "${CYAN}  - Subscription ID: ${YELLOW}$SUBSCRIPTION_ID${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}🎯 Features Included:${NC}"
echo -e "${CYAN}  - Windows VMSS with Azure Monitor Agent${NC}"
echo -e "${CYAN}  - Ubuntu VM with Syslog DCR${NC}"
echo -e "${CYAN}  - Windows VM for monitoring${NC}"
echo -e "${CYAN}  - Red Hat VM with CEF DCR for Sentinel${NC}"
echo -e "${CYAN}  - Auto-shutdown configured for 7:00 PM (your timezone)${NC}"
echo -e "${CYAN}  - Network security and monitoring setup${NC}"
echo -e "${CYAN}  - Common 'azureuser' account across all resources${NC}"
echo -e "${CYAN}  - Secure password with complexity validation${NC}"
echo ""
echo -e "${CYAN}⏰ Auto-shutdown will be configured automatically based on your system timezone.${NC}"
echo -e "${CYAN}💡 All VMs and VMSS will shutdown at 7:00 PM.${NC}"
echo -e "${CYAN}🔐 All resources use 'azureuser' with your secure password.${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🚀 Starting Deployment Process...${NC}"
echo -e "${BLUE}========================================${NC}"

cd ~/amelabs/azmon-lab-agents-essentials/scripts
chmod +x deploy-monitoring-viaCLI.sh
bash deploy-monitoring-viaCLI.sh
