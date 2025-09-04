#!/bin/bash

# Azure Monitor AMPLS Lab Deployment Script
# Usage: ./init-lab.sh [custom-prefix]
# Example: ./init-lab.sh "mylab" (creates app-mylab-java, app-mylab-dotnet)
# If no prefix provided, uses azmon-MMDD-HHMM to avoid conflicts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Clone the repo (skip if already cloned)
if [ ! -d "amelabs" ]; then
  echo -e "${CYAN}Cloning amelabs repository...${NC}"
  git clone https://github.com/microsoft/amelabs.git
fi

# -------------------------------
# Functions
# -------------------------------

# Function to prompt for user input with validation
prompt_input() {
  local prompt_text="$1"
  local var_name="$2"
  local default_value="$3"
  
  while true; do
    if [ -n "$default_value" ]; then
      read -p "$(echo -e "${CYAN}$prompt_text [$default_value]: ${NC}")" user_input
      user_input=${user_input:-$default_value}
    else
      read -p "$(echo -e "${CYAN}$prompt_text: ${NC}")" user_input
    fi
    
    if [ -n "$user_input" ]; then
      eval "$var_name='$user_input'"
      break
    else
      echo -e "${RED}This field cannot be empty. Please try again.${NC}"
    fi
  done
}

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


# Register necessary Azure providers
echo -e "${CYAN}Registering Azure providers...${NC}"
for ns in Microsoft.Insights Microsoft.OperationalInsights Microsoft.Monitor Microsoft.Security Microsoft.Compute Microsoft.SecurityInsights Microsoft.Dashboard; do
  register_provider "$ns"
done


echo -e "${CYAN}Please provide the following configuration values:${NC}"
echo ""

# Prompt for deployment parameters
prompt_input "Enter the name for the Azure Resource Group" RESOURCE_GROUP
prompt_input "Enter the Azure location (e.g., uksouth)" LOCATION
prompt_input "Enter the name for the Log Analytics Workspace" WORKSPACE_NAME
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

# Navigate to the project directory
cd amelabs/azmon-lab-ampls-appinsights/environments/prod

# Allow user to specify a custom prefix to avoid naming conflicts
TIMESTAMP=$(date +%m%d-%H%M)
CUSTOM_PREFIX=${1:-"azmon-${TIMESTAMP}"}
echo -e "${CYAN}Using prefix: ${CUSTOM_PREFIX}${NC}"

echo -e "${CYAN}Initializing Terraform...${NC}"
terraform init

echo -e "${CYAN}Planning Terraform deployment...${NC}"
terraform plan \
  -var="app_service_prefix=${CUSTOM_PREFIX}" \
  -var="resource_group_name=${RESOURCE_GROUP}" \
  -var="location=${LOCATION}" \
  -var="log_analytics_workspace_name=${WORKSPACE_NAME}" \
  -var="admin_password=${ADMIN_PASSWORD}" \
  -var="autoshutdown_time=${USER_TIMEZONE}" \
  -var="autoshutdown_timezone=UTC"

echo -e "${CYAN}Applying Terraform configuration...${NC}"
terraform apply -auto-approve \
  -var="app_service_prefix=${CUSTOM_PREFIX}" \
  -var="resource_group_name=${RESOURCE_GROUP}" \
  -var="location=${LOCATION}" \
  -var="log_analytics_workspace_name=${WORKSPACE_NAME}" \
  -var="admin_password=${ADMIN_PASSWORD}" \
  -var="autoshutdown_time=${USER_TIMEZONE}" \
  -var="autoshutdown_timezone=UTC"

echo -e "${GREEN}Terraform deployment completed successfully!${NC}"

# Display deployment summary
echo -e "${CYAN}===============================================${NC}"
echo -e "${CYAN}         DEPLOYMENT SUMMARY${NC}"
echo -e "${CYAN}===============================================${NC}"
echo -e "${GREEN}Resource Group:       ${RESOURCE_GROUP}${NC}"
echo -e "${GREEN}Location:             ${LOCATION}${NC}"
echo -e "${GREEN}Workspace Name:       ${WORKSPACE_NAME}${NC}"
echo -e "${GREEN}App Service Prefix:   ${CUSTOM_PREFIX}${NC}"
echo -e "${GREEN}Auto-shutdown Time:   ${USER_TIMEZONE} UTC${NC}"
echo -e "${CYAN}===============================================${NC}"

# Capture outputs into variables (while still in the terraform directory)
DEPLOYED_RG=$(terraform output -raw resource_group_name)
APP_SERVICE=$(terraform output -raw app_service_plan_name)
JAVA_WEBAPP_NAME=$(terraform output -raw java_webapp_name)
DOTNET_WEBAPP_NAME=$(terraform output -raw dotnet_webapp_name)
NODE_WEBAPP_NAME=$(terraform output -raw node_webapp_name)

# Confirm deployed values
echo -e "${CYAN}Deployed Resources:${NC}"
echo "RG=$DEPLOYED_RG, APP_SERV=$APP_SERVICE, Java=$JAVA_WEBAPP_NAME, Dotnet=$DOTNET_WEBAPP_NAME, Node=$NODE_WEBAPP_NAME"

# Wait for App Service to be fully ready for deployments
echo -e "${YELLOW}Waiting for App Services to be fully initialized...${NC}"
sleep 60

# Navigate back to the project root for the application deployments
cd ../../

# Deploy Java Application
echo -e "${CYAN}Starting Java application deployment...${NC}"
if [ -f "scripts/install-appservice-java.sh" ]; then
    chmod +x scripts/install-appservice-java.sh
    ./scripts/install-appservice-java.sh "$DEPLOYED_RG" "$JAVA_WEBAPP_NAME"
else
    echo -e "${RED}Error: scripts/install-appservice-java.sh not found${NC}"
    exit 1
fi

# Deploy .NET Application
echo -e "${CYAN}Starting .NET application deployment...${NC}"
if [ -f "scripts/install-appservice-dotnet.sh" ]; then
    chmod +x scripts/install-appservice-dotnet.sh
    ./scripts/install-appservice-dotnet.sh "$DEPLOYED_RG" "$DOTNET_WEBAPP_NAME"
else
    echo -e "${RED}Error: scripts/install-appservice-dotnet.sh not found${NC}"
    exit 1
fi

# Deploy Node.js Application
echo -e "${CYAN}Starting Node.js application deployment...${NC}"
if [ -f "scripts/install-appservice-nodejs.sh" ]; then
    chmod +x scripts/install-appservice-nodejs.sh
    ./scripts/install-appservice-nodejs.sh "$DEPLOYED_RG" "$NODE_WEBAPP_NAME" "$APP_SERVICE"
else
    echo -e "${RED}Error: scripts/install-appservice-nodejs.sh not found${NC}"
    exit 1
fi

echo -e "${GREEN}All deployments completed successfully!${NC}"
echo -e "${CYAN}Application URLs:${NC}"
echo -e "  Java:    https://$JAVA_WEBAPP_NAME.azurewebsites.net"
echo -e "  .NET:    https://$DOTNET_WEBAPP_NAME.azurewebsites.net"
echo -e "  Node.js: https://$NODE_WEBAPP_NAME.azurewebsites.net"
