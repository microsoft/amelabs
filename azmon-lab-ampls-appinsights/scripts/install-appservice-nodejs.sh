#!/bin/bash

# Azure Monitor AMPLS - Node.js Application Deployment Script
# Usage: ./install-appservice-nodejs.sh <resource_group> <node_webapp_name> <app_service_plan>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Read input parameters
if [ $# -ne 3 ]; then
    echo -e "${RED}Error: Invalid number of arguments${NC}"
    echo "Usage: $0 <resource_group> <node_webapp_name> <app_service_plan>"
    exit 1
fi

RESOURCE_GROUP=$1
NODE_WEBAPP_NAME=$2
APP_SERVICE_PLAN=$3

# Validate parameters
if [ -z "$RESOURCE_GROUP" ] || [ -z "$NODE_WEBAPP_NAME" ] || [ -z "$APP_SERVICE_PLAN" ]; then
    echo -e "${RED}Error: All parameters (resource group, webapp name, app service plan) cannot be empty${NC}"
    exit 1
fi

echo -e "${CYAN}Starting Node.js application deployment...${NC}"
echo -e "${CYAN}Resource Group: ${RESOURCE_GROUP}${NC}"
echo -e "${CYAN}Web App Name: ${NODE_WEBAPP_NAME}${NC}"
echo -e "${CYAN}App Service Plan: ${APP_SERVICE_PLAN}${NC}"

# Deploy Node.js Application
echo -e "${CYAN}Deploying Node.js sample application...${NC}"

# Check if the repository already exists
if [ ! -d "node-ai-demo" ]; then
    git clone https://github.com/tiagojfernandes/node-ai-demo.git
fi

cd node-ai-demo

# Install dependencies locally first to ensure they're available
echo -e "${CYAN}Installing Node.js dependencies...${NC}"
npm install

# Fix security vulnerabilities  
npm audit fix --force

# Create a deployment package with node_modules included
echo -e "${CYAN}Creating deployment package...${NC}"
zip -r ../node-app.zip . -x "*.git*" "*.vscode*" "README.md"

# Deploy using az webapp deploy (which preserves node_modules)
echo -e "${CYAN}Deploying to Azure App Service...${NC}"
az webapp deploy \
  --resource-group $RESOURCE_GROUP \
  --name $NODE_WEBAPP_NAME \
  --src-path ../node-app.zip \
  --type zip

# Wait a moment for deployment to process
echo -e "${YELLOW}Waiting for Node.js deployment to complete...${NC}"
sleep 30

# Verify the deployment worked
echo -e "${CYAN}Checking Node.js app deployment status...${NC}"
for i in {1..12}; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://${NODE_WEBAPP_NAME}.azurewebsites.net/healthz" || echo "000")
    if [ "$HTTP_CODE" == "200" ]; then
        echo -e "${GREEN}Node.js app is responding successfully!${NC}"
        break
    fi
    echo "Attempt $i/12: Node.js app not ready yet (HTTP $HTTP_CODE), waiting 10 more seconds..."
    sleep 10
done

echo -e "${GREEN}Node.js application deployed to $NODE_WEBAPP_NAME${NC}"
echo -e "${CYAN}Node.js app URL: https://$NODE_WEBAPP_NAME.azurewebsites.net${NC}"
echo -e "${CYAN}Health check: https://$NODE_WEBAPP_NAME.azurewebsites.net/healthz${NC}"