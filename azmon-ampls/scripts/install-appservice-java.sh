#!/bin/bash

# Azure Monitor AMPLS - Java Application Deployment Script
# Usage: ./install-appservice-java.sh <resource_group> <java_webapp_name>

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
    echo "Usage: $0 <resource_group> <java_webapp_name>"
    exit 1
fi

RESOURCE_GROUP=$1
JAVA_WEBAPP_NAME=$2

# Validate parameters
if [ -z "$RESOURCE_GROUP" ] || [ -z "$JAVA_WEBAPP_NAME" ]; then
    echo -e "${RED}Error: Resource group and webapp name cannot be empty${NC}"
    exit 1
fi

echo -e "${CYAN}Starting Java application deployment...${NC}"
echo -e "${CYAN}Resource Group: ${RESOURCE_GROUP}${NC}"
echo -e "${CYAN}Web App Name: ${JAVA_WEBAPP_NAME}${NC}"

# Deploy Java Application
echo -e "${CYAN}Cloning Java samples repository...${NC}"
if [ ! -d "ApplicationInsights-Java-Samples" ]; then
    git clone https://github.com/Azure-Samples/ApplicationInsights-Java-Samples.git
else
    echo -e "${YELLOW}Java samples repository already exists, using existing copy${NC}"
fi

cd ApplicationInsights-Java-Samples

echo -e "${CYAN}Building Java sample application...${NC}"

# Check if Java is available
if ! command -v java &> /dev/null; then
    echo -e "${YELLOW}Java is not installed or not in PATH. Skipping Java application build.${NC}"
    echo -e "${YELLOW}You can manually build and deploy the Java app later with:${NC}"
    echo -e "${YELLOW}  cd ApplicationInsights-Java-Samples${NC}"
    echo -e "${YELLOW}  ./mvnw package -DskipTests -pl maven${NC}"
    echo -e "${YELLOW}  az webapp deploy --resource-group $RESOURCE_GROUP --name $JAVA_WEBAPP_NAME --src-path maven/target/app.jar${NC}"
else
    # Build the maven project from the root directory using the appropriate wrapper
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows environment
        ./mvnw.cmd package -DskipTests -pl maven
    else
        # Unix/Linux environment
        ./mvnw package -DskipTests -pl maven
    fi

    # Check if build was successful
    if [ -f "maven/target/app.jar" ]; then
        echo -e "${GREEN}Java application built successfully!${NC}"
        
        # Check what we have in target directory
        echo -e "${CYAN}Contents of maven/target:${NC}"
        ls -la maven/target/
        
        # Prepare deployment directory with proper structure
        rm -rf deploy_temp  # Clean up any existing directory
        mkdir -p deploy_temp
        
        # Copy files and verify
        cp maven/target/app.jar deploy_temp/
        if [ -d "maven/target/agent" ]; then
            cp -r maven/target/agent deploy_temp/
            echo -e "${CYAN}Copied agent directory${NC}"
        else
            echo -e "${YELLOW}Warning: agent directory not found in maven/target/${NC}"
        fi
        
        # Show what we're deploying
        echo -e "${CYAN}Contents of deploy_temp:${NC}"
        ls -la deploy_temp/
        
        # Verify permissions
        chmod -R 755 deploy_temp
        
        # Deploy the Java application (directory structure)
        cd deploy_temp
        zip -r ../app_with_agent.zip .
        cd ..
        
        az webapp deploy \
          --resource-group $RESOURCE_GROUP \
          --name $JAVA_WEBAPP_NAME \
          --src-path app_with_agent.zip \
          --type zip
          
        echo -e "${GREEN}Java application deployed to $JAVA_WEBAPP_NAME${NC}"
        
        # Cleanup
        rm -rf deploy_temp
        rm -f app_with_agent.zip
    else
        echo -e "${RED}Build failed - app.jar not found${NC}"
    fi
fi