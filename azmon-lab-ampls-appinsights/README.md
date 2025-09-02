# Azure Monitor AMPLS + AppInsights Lab Environment

This lab demonstrates Azure Monitor Private Link Scope (AMPLS) implementation with a hub-and-spoke network topology, featuring private-only monitoring for multi-platform applications.

## 🚀 Quick Start (Recommended)

**The easiest way to deploy this lab is using Azure Portal Bash:**

1. Open [Azure Portal](https://portal.azure.com)
2. Click on the **Cloud Shell** icon (terminal icon in the top menu)
3. Select **Bash** when prompted
4. Run this single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/microsoft/amelabs/refs/heads/main/azmon-lab-ampls-appinsights/init-lab.sh)
```

The deployment takes about 25-30 minutes. You'll be prompted for configuration options during setup.

## 🏗️ Architecture

This lab creates the following Azure resources:

- **Hub-and-Spoke Network**: Central hub VNet with Windows, Ubuntu, and App Service spoke VNets
- **Azure Monitor Private Link Scope (AMPLS)**: Private-only ingestion and query for monitoring data
- **Windows VM** with Azure Monitor Agent
- **Ubuntu VM** with Azure Monitor Agent
- **App Service Plan** hosting multi-platform applications (Java, .NET, Node.js)
- **Log Analytics Workspace** with private connectivity
- **Application Insights** with private endpoints
- **Private DNS Zones** for endpoint resolution
- **Network Security Groups** with appropriate security rules

<img width="1341" height="1638" alt="image" src="https://github.com/user-attachments/assets/3121767c-1dd6-4d6e-9df3-1e359d0f20e4" />

## 🔧 Features

### Private Link Architecture

- **AMPLS Configuration**: Private-only ingestion and query access modes enforce network isolation
- **Hub-and-Spoke Design**: Centralized private endpoints in hub VNet with secure spoke connectivity
- **DNS Integration**: Private DNS zones automatically resolve Azure Monitor endpoints to private IPs
- **Network Peering**: Bidirectional VNet peering enables secure cross-network communication

### Multi-Platform Application Monitoring

#### App Service Applications

Three production-ready applications demonstrating different technology stacks:
- **Java Spring Boot**: Actuator endpoints with Application Insights integration
- **.NET Core**: ASP.NET Core with built-in health checks and telemetry
- **Node.js Express**: Custom metrics and monitoring middleware

All applications use:
- VNet integration with dedicated App Service spoke network
- Private-only telemetry ingestion through AMPLS
- Consistent Application Insights instrumentation

#### Virtual Machine Monitoring

- **Windows VM**: Azure Monitor Agent with performance counter collection + ASP.NET Core app with Application Insights integration
- **Ubuntu VM**: Azure Monitor Agent with syslog monitoring + Python Flask app with Application Insights integration
- **Auto-Shutdown**: Cost optimization with scheduled VM shutdown policies

### Network Security

- **Private Endpoints**: All Azure Monitor traffic flows through private endpoints
- **Network Security Groups**: Minimal required access with proper security rules
- **DNS Zones**: Automatic private DNS resolution for all monitoring endpoints
- **VNet Integration**: App Services communicate securely through dedicated subnet

### Deployment Automation

#### Interactive Setup

- **Guided Configuration**: User-friendly prompts for resource naming and settings
- **Automatic Detection**: Script detects optimal configurations and provides defaults
- **Error Handling**: Comprehensive validation and retry logic
- **Multi-Platform**: Supports Windows PowerShell and Linux Bash environments

#### Infrastructure as Code

- **Terraform Modules**: Modular, reusable infrastructure components
- **Environment Management**: Separate configurations for different deployment scenarios
- **State Management**: Proper Terraform state handling and backend configuration

---

## 📋 Manual Deployment (Optional)

### Prerequisites
- Azure CLI installed and configured
- Terraform 1.0+ installed
- Appropriate Azure permissions to create resources

### Deploy
```bash
git clone https://github.com/microsoft/amelabs.git
cd azmon-lab-ampls-appinsights
./init-lab.sh
```

## 🧹 Cleanup

```bash
cd environments/prod
terraform destroy
```
