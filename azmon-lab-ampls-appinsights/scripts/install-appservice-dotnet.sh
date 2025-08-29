#!/bin/bash

# Azure Monitor AMPLS - .NET Application Deployment Script
# Usage: ./install-appservice-dotnet.sh <resource_group> <dotnet_webapp_name>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Read input parameters
if [ $# -ne 2 ]; then
    echo -e "${RED}Error: Invalid number of arguments${NC}"
    echo "Usage: $0 <resource_group> <dotnet_webapp_name>"
    exit 1
fi

RESOURCE_GROUP=$1
DOTNET_WEBAPP_NAME=$2

# Validate parameters
if [ -z "$RESOURCE_GROUP" ] || [ -z "$DOTNET_WEBAPP_NAME" ]; then
    echo -e "${RED}Error: Resource group and webapp name cannot be empty${NC}"
    exit 1
fi

echo -e "${CYAN}Starting .NET application deployment...${NC}"
echo -e "${CYAN}Resource Group: ${RESOURCE_GROUP}${NC}"
echo -e "${CYAN}Web App Name: ${DOTNET_WEBAPP_NAME}${NC}"

# Deploy .NET Application
echo -e "${CYAN}Deploying .NET sample application...${NC}"

# Check if the samples repository already exists
if [ ! -d "quickstart-deploy-aspnet-core-app-service" ]; then
    echo -e "${CYAN}Cloning .NET quickstart repository...${NC}"
    git clone https://github.com/Azure-Samples/quickstart-deploy-aspnet-core-app-service.git
else
    echo -e "${YELLOW}.NET quickstart repository already exists, using existing copy${NC}"
fi

cd quickstart-deploy-aspnet-core-app-service/src

# Check if dotnet is available
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}Error: .NET SDK is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install .NET SDK and try again${NC}"
    exit 1
fi

# Build and publish the application
echo -e "${CYAN}Building .NET application...${NC}"
if dotnet publish -c Release -o ./publish; then
    echo -e "${GREEN}.NET application built successfully!${NC}"
    
    # Verify publish directory exists and has content
    if [ -d "./publish" ] && [ "$(ls -A ./publish)" ]; then
        echo -e "${CYAN}Publish directory contains:${NC}"
        ls -la ./publish | head -10
        
        # Create deployment package
        echo -e "${CYAN}Creating deployment package...${NC}"
        cd publish
        zip -r ../../dotnet-app.zip .
        cd ..
        
        # Verify zip file was created
        if [ -f "../dotnet-app.zip" ]; then
            echo -e "${GREEN}Deployment package created successfully ($(du -h ../dotnet-app.zip | cut -f1))${NC}"
        else
            echo -e "${RED}Error: Failed to create deployment package${NC}"
            exit 1
        fi
        
        # Deploy the .NET application
        echo -e "${CYAN}Deploying to Azure App Service...${NC}"
        if az webapp deploy \
            --resource-group $RESOURCE_GROUP \
            --name $DOTNET_WEBAPP_NAME \
            --src-path ../dotnet-app.zip \
            --type zip; then
            echo -e "${GREEN}.NET deployment completed successfully${NC}"
        else
            echo -e "${RED}Error: .NET deployment failed${NC}"
            exit 1
        fi
        
        # Configure startup file
        echo -e "${CYAN}Configuring startup file...${NC}"
        if az webapp config set \
            --resource-group $RESOURCE_GROUP \
            --name $DOTNET_WEBAPP_NAME \
            --startup-file MyAzureWebApp; then
            echo -e "${GREEN}Startup file configured successfully${NC}"
        else
            echo -e "${YELLOW}Warning: Failed to configure startup file${NC}"
        fi
        
        # Restart the web app
        echo -e "${CYAN}Restarting web app...${NC}"
        if az webapp restart \
            --resource-group $RESOURCE_GROUP \
            --name $DOTNET_WEBAPP_NAME; then
            echo -e "${GREEN}Web app restarted successfully${NC}"
        else
            echo -e "${YELLOW}Warning: Failed to restart web app${NC}"
        fi
        
        # Wait for deployment to process
        echo -e "${YELLOW}Waiting for .NET deployment to complete...${NC}"
        sleep 45
        
        # Verify the deployment worked
        echo -e "${CYAN}Checking .NET app deployment status...${NC}"
        for i in {1..15}; do
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://${DOTNET_WEBAPP_NAME}.azurewebsites.net" || echo "000")
            if [ "$HTTP_CODE" == "200" ]; then
                echo -e "${GREEN}.NET app is responding successfully!${NC}"
                break
            elif [ "$HTTP_CODE" == "500" ] || [ "$HTTP_CODE" == "502" ] || [ "$HTTP_CODE" == "503" ]; then
                echo "Attempt $i/15: .NET app returning error $HTTP_CODE, waiting 15 more seconds..."
                sleep 15
            else
                echo "Attempt $i/15: .NET app not ready yet (HTTP $HTTP_CODE), waiting 10 more seconds..."
                sleep 10
            fi
        done
        
        echo -e "${GREEN}.NET application deployed to $DOTNET_WEBAPP_NAME${NC}"
        echo -e "${CYAN}.NET app URL: https://$DOTNET_WEBAPP_NAME.azurewebsites.net${NC}"
        
    else
        echo -e "${RED}Error: Publish directory is empty or doesn't exist${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: .NET build failed${NC}"
    exit 1
fi

# Return to project root and cleanup
cd ../../../
rm -f ../dotnet-app.zip