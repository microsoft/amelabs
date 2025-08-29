#!/bin/bash

# -----------------------------------------------------------------------------
# deploy-aks-managedsolutions.sh
# AKS and managed solutions deployment script for Azure monitoring lab
# 
# Usage: ./deploy-aks-managedsolutions.sh <RESOURCE_GROUP> <WORKSPACE_ID> <WORKSPACE_NAME> <AKS_CLUSTER> <MANAGED_GRAFANA> <PROM_NAME>
# -----------------------------------------------------------------------------

set -e

# Color codes for better user experience
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if required parameters are provided
if [ $# -ne 6 ]; then
    echo -e "${RED}Usage: $0 <RESOURCE_GROUP> <WORKSPACE_ID> <WORKSPACE_NAME> <AKS_CLUSTER> <MANAGED_GRAFANA> <PROM_NAME>${NC}"
    echo ""
    echo -e "${CYAN}Parameters:${NC}"
    echo -e "${CYAN}  RESOURCE_GROUP  - Name of the Azure resource group${NC}"
    echo -e "${CYAN}  WORKSPACE_ID    - Full resource ID of the Log Analytics workspace${NC}"
    echo -e "${CYAN}  WORKSPACE_NAME  - Name of the Log Analytics workspace${NC}"
    echo -e "${CYAN}  AKS_CLUSTER     - Name of the the AKS cluster${NC}"
    echo -e "${CYAN}  MANAGED_GRAFANA - Name of the the Managed Grafana${NC}"
    echo -e "${CYAN}  PROM_NAME       - Name of the Azure Monitor Workspace(Managed Prometheus)${NC}"
    exit 1
fi
#
#echo "Choose a name for your AKS cluster:"
#read AKS_CLUSTER
#
#echo "Choose a name for your Managed Prometheus:"
#read PROM_NAME
#
#echo "Choose a name for your Managed Grafana:"
#read MANAGED_GRAFANA
#

# Assign input parameters to variables
RESOURCE_GROUP="$1"
WORKSPACE_ID="$2"
WORKSPACE_NAME="$3"
AKS_CLUSTER="$4"
MANAGED_GRAFANA="$5"
PROM_NAME="$6"

echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}Starting AKS and Managed Solutions Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}Resource Group: ${YELLOW}$RESOURCE_GROUP${NC}"
echo -e "${CYAN}Log Analytics Workspace: ${YELLOW}$WORKSPACE_NAME${NC}"
echo -e "${CYAN}AKS Cluster: ${YELLOW}$AKS_CLUSTER${NC}"
echo -e "${CYAN}Managed Grafana: ${YELLOW}$MANAGED_GRAFANA${NC}"
echo -e "${CYAN}Managed Prometheus: ${YELLOW}$PROM_NAME${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Avoid extension installing confirmation
echo -e "${CYAN}Configuring Azure CLI extensions...${NC}"
az config set extension.use_dynamic_install=yes_without_prompt
#
# Create a Managed Prometheus (Azure monitor Workspace) in the New Resource Group
echo ""
echo -e "${BLUE}Step 1/4: ${CYAN}Creating Managed Prometheus (Azure Monitor Workspace)...${NC}"
echo -e "${CYAN}Name: ${YELLOW}$PROM_NAME${NC}"
az monitor account create -g $1 -n $6 
echo -e "${GREEN}✓ Managed Prometheus created successfully${NC}" 
#
# Create a Managed Grafana in the New Resource Group
echo ""
echo -e "${BLUE}Step 2/4: ${CYAN}Creating Managed Grafana...${NC}"
echo -e "${CYAN}Name: ${YELLOW}$MANAGED_GRAFANA${NC}"
az grafana create --resource-group $1 --name $5
echo -e "${GREEN}✓ Managed Grafana created successfully${NC}"
#
# Create an AKS Cluster in the New Resource Group with Monitoring addon Enabled
#
echo ""
echo -e "${BLUE}Step 3/4: ${CYAN}Creating AKS cluster with monitoring enabled...${NC}"
echo -e "${CYAN}Cluster name: ${YELLOW}$AKS_CLUSTER${NC}"
echo -e "${CYAN}Node count: ${YELLOW}2${NC}"
echo -e "${CYAN}Retrieving Log Analytics workspace ID...${NC}"
# The first command retrieves the ID of a specified Log Analytics workspace and stores it in the workspaceId variable.
workspaceId=$(az monitor log-analytics workspace show --resource-group $1 --workspace-name $3 --query id -o tsv)
echo -e "${CYAN}Log Analytics workspace ID: ${YELLOW}$workspaceId${NC}"
#
echo -e "${CYAN}Creating AKS cluster (this may take several minutes)...${NC}"
# The second command creates an AKS cluster with monitoring enabled, linking it to the Log Analytics workspace using the retrieved ID. This setup integrates Azure Monitor for containers with the AKS cluster.
az aks create -g $1 -n $4 --node-count 2 --enable-addons monitoring --generate-ssh-keys --workspace-resource-id $workspaceId
echo -e "${GREEN}✓ AKS cluster created successfully${NC}"
#
echo ""
echo -e "${BLUE}Step 4/4: ${CYAN}Configuring AKS cluster with Managed Prometheus and Grafana...${NC}"
echo -e "${CYAN}Retrieving Managed Prometheus ID...${NC}"
# The third command retrieves the ID of a specified Managed Prometheus and stores it in the workspaceId variable.
prometheusId=$(az monitor account show --resource-group $1 -n $6 --query id -o tsv)
echo -e "${CYAN}Prometheus ID: ${YELLOW}$prometheusId${NC}"
#
echo -e "${CYAN}Retrieving Managed Grafana ID...${NC}"
# The fourth command retrieves the ID of a specified Managed Grafana and stores it in the workspaceId variable.
grafanaId=$(az grafana show --resource-group $1 -n $5 --query id -o tsv)
echo -e "${CYAN}Grafana ID: ${YELLOW}$grafanaId${NC}"
#
echo -e "${CYAN}Updating AKS cluster to enable Azure Monitor metrics...${NC}"
# The fifth update the AKS cluster to be monitored by Managed Prometheus and Managed Grafana
az aks update --enable-azure-monitor-metrics -n $4 -g $1 --azure-monitor-workspace-resource-id $prometheusId --grafana-resource-id $grafanaId
echo -e "${GREEN}✓ AKS cluster updated with Managed Prometheus and Grafana integration${NC}"
#
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ AKS and Managed Solutions Deployment Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}Resources created:${NC}"
echo -e "${CYAN}  • AKS Cluster: ${YELLOW}$AKS_CLUSTER${NC}"
echo -e "${CYAN}  • Managed Prometheus: ${YELLOW}$PROM_NAME${NC}"
echo -e "${CYAN}  • Managed Grafana: ${YELLOW}$MANAGED_GRAFANA${NC}"
echo -e "${CYAN}  • Log Analytics integration enabled${NC}"
echo -e "${BLUE}========================================${NC}"










