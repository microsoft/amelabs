# Azure Monitoring Lab

A comprehensive Azure monitoring lab environment built with Terraform and automated with Bash scripts. This lab deploys virtual machines, VMSS, AKS, Log Analytics workspace, Sentinel, and Azure Monitor components.

## 🚀 Quick Start (Recommended)

**The easiest way to deploy this lab is using Azure Portal Bash - no local setup required!**

### One-Liner Deployment

1. Open [Azure Portal](https://portal.azure.com)
2. Click on the **Cloud Shell** icon (terminal icon in the top menu)
3. Select **Bash** when prompted (first-time users)
4. Run this single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/microsoft/amelabs/refs/heads/main/azmon-lab-agents-essentials/init-lab.sh)
```

### What You Get

This lab creates a comprehensive Azure monitoring environment:

- **Infrastructure Monitoring**: VMSS, VMs (Ubuntu, Windows, Red Hat), and AKS cluster
- **Centralized Logging**: Log Analytics workspace with Sentinel integration  
- **Advanced Monitoring**: Azure Monitor Agent (AMA) with Data Collection Rules (DCRs)
- **Visualization**: Azure Managed Grafana with Prometheus metrics
- **Security Monitoring**: CEF log simulation and Syslog collection
- **Cost Management**: Automated shutdown policies for all compute resources

### Deployment Details

- **Duration**: 25-30 minutes for complete setup
- **Interaction**: You'll be prompted for resource names and Azure region selection
- **Authentication**: Uses your current Azure Portal session (no separate login required)
- **Cost Optimization**: All VMs configured with 7:00 PM local time auto-shutdown

## 🏗️ Architecture

This lab focuses on **infrastructure and platform monitoring** with enterprise-grade logging and security monitoring capabilities:

### Core Infrastructure
- **Resource Group** with centralized Log Analytics workspace
- **Windows Virtual Machine Scale Set (VMSS)** for scalable monitoring scenarios
- **Multi-Platform VMs**: Ubuntu (Syslog), Windows (Events), Red Hat (CEF/Sentinel)
- **Azure Kubernetes Service (AKS)** cluster with container monitoring

### Monitoring & Observability Stack
- **Azure Monitor Agent (AMA)** - Next-generation monitoring agent on all VMs
- **Data Collection Rules (DCRs)** - Targeted log collection with fine-grained control
- **Azure Managed Grafana** - Enterprise visualization and alerting platform
- **Azure Monitor Workspace (Managed Prometheus)** - Cloud-native metrics collection
- **Microsoft Sentinel** - SIEM integration via CEF logs

### Automation & Cost Management
- **Azure Automation Account** - PowerShell runbooks for VMSS lifecycle management
- **Auto-shutdown Policies** - 7:00 PM local time shutdown for all compute resources
- **Network Security Groups** - Least-privilege access with IP restrictions

<img width="1171" height="1177" alt="image" src="https://github.com/user-attachments/assets/4617964d-031f-4e24-a952-2a0c838c6272" />

### 🎯 Lab Focus & Use Cases

This lab is designed for **infrastructure monitoring and security operations** scenarios:

- **Azure Monitor Agent (AMA) Adoption** - Experience next-gen monitoring with DCRs
- **Multi-Platform Monitoring** - Windows, Linux, and container workloads  
- **SIEM Integration** - Sentinel integration via CEF logs and security monitoring
- **Scalable Monitoring** - VMSS scenarios for enterprise-scale environments
- **Container Monitoring** - AKS with Prometheus and Grafana integration
- **Cost Optimization** - Automated shutdown and resource lifecycle management

**Complementary to AMPLS Lab**: While the AMPLS lab focuses on application monitoring with private network connectivity, this lab emphasizes platform monitoring, security operations, and agent-based data collection.

---

## 📋 Manual Deployment (Optional)

**Advanced users who prefer local development can deploy manually:**

### Prerequisites

#### Core Infrastructure Tools
- **Azure CLI** (latest version) - for Azure resource management
- **Terraform** >= 1.3.0 - for infrastructure as code deployment  
- **Git** - for repository cloning
- **Bash Shell** - for script execution (Linux/macOS/WSL)

#### ⚠️ Note on Software Requirements
Manual deployment requires setting up these tools locally, while **Azure Portal Bash (recommended above) has everything pre-installed** and ready to use.

### Deploy
```bash
git clone https://github.com/microsoft/amelabs.git
cd amelabs/azmon-lab-agents-essentials
chmod +x scripts/deploy-monitoring-viaCLI.sh
./scripts/deploy-monitoring-viaCLI.sh
```

## 🧹 Cleanup

### Azure Portal Bash Deployment
Resources deployed via the one-liner command can be cleaned up directly in the Azure Portal:

1. Navigate to **Resource Groups** in the Azure Portal
2. Find your lab resource group (e.g., `rg-azmon-lab`)
3. Click **Delete resource group**
4. Type the resource group name to confirm
5. Click **Delete**

### Manual Deployment  
For manual deployments using the Terraform utility:

```bash
cd terraform
terraform destroy -var-file="environments/default/terraform.tfvars"
```

## 🔧 Features

### Auto-Shutdown Configuration

The lab automatically configures auto-shutdown for all VMs and VMSS to help manage costs:

- **Shutdown Time**: 7:00 PM in your local timezone (converted to UTC automatically)
- **Notification**: 15 minutes before shutdown
- **Time Calculation**: Scripts automatically calculate the corresponding UTC time based on your local timezone
- **Resources**: All VMs and VMSS are configured with auto-shutdown policies
- **VMSS Automation**: Azure Automation Runbook deployed for VMSS shutdown automation (scheduled PowerShell runbook)

The deployment script automatically:
1. Detects your local timezone
2. Calculates what 7:00 PM in your local time corresponds to in UTC
3. Configures auto-shutdown for VMs using Azure CLI
4. Deploys a scheduled Azure Automation Runbook for VMSS shutdown (since VMSS doesn't support native auto-shutdown)

**Example:**
- If you're in EST (UTC-5) and want 7:00 PM shutdown
- Script calculates: 7:00 PM EST = 12:00 AM UTC (next day)
- Auto-shutdown configured for 0000 UTC
- Azure Automation Runbook scheduled for the same time

This approach works around Azure CLI limitations with timezone parameters and ensures accurate scheduling regardless of your location.

### Monitoring and Logging

#### Data Collection Rules (DCRs)

- **CEF DCR**: Configured for Red Hat VM to collect CEF messages for Sentinel
- **Syslog DCR**: Configured for Ubuntu VM to collect all syslog facilities

#### Azure Monitor Agent (AMA)

- Deployed on all VMs with system-assigned managed identity
- Proper role assignments for metric publishing
- Automated association with appropriate DCRs

#### Network Security

- SSH access (port 22) for Linux VMs
- RDP access (port 3389) for Windows VMs
- HTTP/HTTPS access (ports 80/443)
- Syslog and CEF ports (514) for log forwarding
- Source IP restriction to your public IP

### Post-Deployment Automation

#### AMA Forwarder (Red Hat VM)

Automatically installs and configures:
- rsyslog service for CEF message forwarding
- Log rotation for /var/log/cef.log
- Service restart and enablement

#### CEF Simulator (Ubuntu VM)

Installs a CEF message generator that:
- Sends simulated security events to Red Hat VM
- Supports multiple vendor formats (PaloAlto, CyberArk, Fortinet)
- Runs every 30 seconds via cron

#### VMSS Auto-Shutdown Automation

Deploys an Azure Automation Account with a scheduled runbook for VMSS auto-shutdown:
- **Platform**: Azure Automation Account with PowerShell runbook
- **Trigger**: Schedule-based (configurable timing)
- **Authentication**: Managed Identity with appropriate RBAC permissions
- **Functionality**: Automatically deallocates VMSS instances at scheduled time
- **Robust Deployment**: Includes retry logic and proper error handling
- **Timezone Support**: Schedule dynamically calculated based on user's local timezone
- **Cost Effective**: No consumption charges, runs on Azure's automation infrastructure

## 📁 Project Structure

```
azmon-labs/
├── terraform/
│   ├── main.tf                    # Main Terraform configuration
│   ├── variables.tf               # Variable definitions
│   ├── outputs.tf                 # Output definitions
│   ├── provider.tf                # Azure provider configuration
│   ├── environments/
│   │   └── default/
│   │       └── terraform.tfvars   # Default variable values
│   └── modules/
│       ├── resource_group/        # Resource group module
│       ├── log_analytics/         # Log Analytics workspace module
│       ├── network/               # Networking module
│       ├── dcr/                   # Data Collection Rules module
│       ├── vm_ubuntu/             # Ubuntu VM module
│       ├── vm_windows/            # Windows VM module
│       ├── vm_redhat/             # Red Hat VM module
│       └── vmss_windows/          # Windows VMSS module
├── scripts/
│   ├── deploy-monitoring-viaCLI.sh    # Main deployment script
│   ├── post-deployment-tasks.sh       # Post-deployment configuration
│   ├── deploy-vmss-autoshutdown.sh    # VMSS auto-shutdown function deployment
│   ├── deploy-aks-managedsolutions.sh # AKS and managed solutions deployment
│   ├── deploy_ama_forwarder.sh        # AMA forwarder installation
│   └── deploy_cef_simulator.sh        # CEF simulator installation
└── README.md                      # This documentation
