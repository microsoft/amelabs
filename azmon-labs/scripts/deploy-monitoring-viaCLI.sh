#!/bin/bash

# deploy-monitoring.sh
# Initial deployment script for the Azure monitoring lab

set -e

# Color codes for better user experience
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🚀 Starting Azure Monitoring Lab Deployment...${NC}"
echo -e "${BLUE}========================================${NC}"

# Change to the project directory
cd ~/azmon-labs

# Initialize and apply Terraform
echo ""
echo -e "${CYAN}📦 Initializing Terraform...${NC}"
cd terraform
terraform init

echo ""
echo -e "${CYAN}📋 Planning Terraform deployment...${NC}"
terraform plan -var-file="environments/default/terraform.tfvars" -out=tfplan

echo ""
echo -e "${CYAN}🔧 Applying Terraform configuration...${NC}"
terraform apply tfplan

echo ""
echo -e "${CYAN}💾 Saving Terraform outputs...${NC}"
terraform output -json > tf_outputs.json

echo -e "${GREEN}✅ Terraform deployment completed!${NC}"

# Load variables from the Terraform output JSON
cd ~
PWD=$(pwd)
TF_OUTPUTS="$PWD/azmon-labs/terraform/tf_outputs.json"


# Checks if the Terraform outputs file exists and loads the necessary variables.
echo ""
echo -e "${CYAN}🔍 Loading Terraform outputs...${NC}"
if [ ! -f "$TF_OUTPUTS" ]; then
  echo -e "${RED}ERROR: Terraform outputs file not found: $TF_OUTPUTS${NC}"
  exit 1
fi


RESOURCE_GROUP=$(jq -r '.resource_group_name.value' "$TF_OUTPUTS")
WORKSPACE_ID=$(jq -r '.log_analytics_workspace_id.value' "$TF_OUTPUTS")
WORKSPACE_NAME=$(jq -r '.log_analytics_workspace_name.value' "$TF_OUTPUTS")
USER_TIMEZONE=$(jq -r '.user_timezone.value' "$TF_OUTPUTS")
REDHAT_VM_NAME=$(jq -r '.redhat_vm_name.value' "$TF_OUTPUTS")
UBUNTU_VM_NAME=$(jq -r '.ubuntu_vm_name.value' "$TF_OUTPUTS")
WINDOWS_VM_NAME=$(jq -r '.windows_vm_name.value' "$TF_OUTPUTS")
VMSS_NAME=$(jq -r '.vmss_name.value' "$TF_OUTPUTS")
REDHAT_PRIVATE_IP=$(jq -r '.redhat_vm_private_ip.value' "$TF_OUTPUTS")
AKS_CLUSTER=$(jq -r '.aks_name.value' "$TF_OUTPUTS")
MANAGED_GRAFANA=$(jq -r '.grafana_name.value' "$TF_OUTPUTS")
PROM_NAME=$(jq -r '.prom_name.value' "$TF_OUTPUTS")
AUTOMATION_ACCOUNT_NAME=$(jq -r '.automation_account_name.value' "$TF_OUTPUTS")

echo -e "${CYAN}Extracted configuration:${NC}"
echo -e "${CYAN}  - AKS Cluster: ${YELLOW}$AKS_CLUSTER${NC}"
echo -e "${CYAN}  - Managed Grafana: ${YELLOW}$MANAGED_GRAFANA${NC}"
echo -e "${CYAN}  - Managed Prometheus: ${YELLOW}$PROM_NAME${NC}"
echo -e "${CYAN}  - Automation Account: ${YELLOW}$AUTOMATION_ACCOUNT_NAME${NC}"


# Run deployment scripts based on az cli
# This section will create aks, prometheus, grafana, and other resources as needed
echo ""
echo -e "${CYAN}🔄 Running AKS and Azure Monitor workspace configuration...${NC}"
cd ~/azmon-labs/scripts
chmod +x deploy-aks-managedsolutions.sh
./deploy-aks-managedsolutions.sh "$RESOURCE_GROUP" "$WORKSPACE_ID" "$WORKSPACE_NAME" "$AKS_CLUSTER" "$MANAGED_GRAFANA" "$PROM_NAME"

# Run post-deployment tasks
echo ""
echo -e "${CYAN}🔄 Running post-deployment configuration...${NC}"
cd ~/azmon-labs/scripts
chmod +x post-deployment-tasks.sh
./post-deployment-tasks.sh "$RESOURCE_GROUP" "$REDHAT_VM_NAME" "$UBUNTU_VM_NAME" "$WINDOWS_VM_NAME" "$VMSS_NAME" "$REDHAT_PRIVATE_IP" "$USER_TIMEZONE"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 Azure Monitoring Lab deployment completed successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}📋 Resources Created:${NC}"
echo -e "${CYAN}  - Resource Group with Log Analytics Workspace${NC}"
echo -e "${CYAN}  - Windows Virtual Machine Scale Set (VMSS)${NC}"
echo -e "${CYAN}  - Ubuntu VM (with Syslog DCR)${NC}"
echo -e "${CYAN}  - Windows VM${NC}"
echo -e "${CYAN}  - Red Hat VM (with CEF DCR for Sentinel)${NC}"
echo -e "${CYAN}  - Network Security Groups and Public IPs${NC}"
echo -e "${CYAN}  - Data Collection Rules (DCRs)${NC}"
echo -e "${CYAN}  - Azure Monitor Agent (AMA) on all VMs${NC}"
echo -e "${CYAN}  - Auto-shutdown configured for all VMs and VMSS${NC}"
echo ""
echo -e "${CYAN}🔧 Post-Deployment Features:${NC}"
echo -e "${CYAN}  - AMA Forwarder installed on Red Hat VM${NC}"
echo -e "${CYAN}  - CEF Simulator installed on Ubuntu VM${NC}"
echo -e "${CYAN}  - Auto-shutdown scheduled for 7:00 PM (detected timezone)${NC}"
echo -e "${CYAN}  - Monitoring and log forwarding configured${NC}"
echo ""
echo -e "${YELLOW}💡 Access your resources in the Azure portal and configure additional monitoring as needed.${NC}"
echo -e "${BLUE}========================================${NC}"
