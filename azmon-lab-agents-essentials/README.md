# Azure Monitoring Lab

A comprehensive Azure monitoring lab environment built with Terraform and automated with Bash scripts. This lab deploys virtual machines, VMSS, AKS, Log Analytics workspace, Sentinel, and Azure Monitor components.

## 🚀 Quick Start (Recommended)

**The easiest way to deploy this lab is using Azure Portal Bash:**

1. Open [Azure Portal](https://portal.azure.com)
2. Click on the **Cloud Shell** icon (terminal icon in the top menu)
3. Select **Bash** when prompted
4. Run this single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/microsoft/amelabs/refs/heads/main/azmon-lab-agents-essentials/init-lab.sh)
```

The deployment takes about 25-30 minutes. You'll be prompted for configuration options during setup.

## 🏗️ Architecture

This lab creates the following Azure resources:

- **Resource Group** with Log Analytics Workspace
- **Windows Virtual Machine Scale Set (VMSS)** for scalable monitoring scenarios
- **Ubuntu VM** with Syslog Data Collection Rule (DCR)
- **Windows VM** for Windows-specific monitoring
- **Red Hat VM** with CEF Data Collection Rule for Sentinel integration
- **Azure Kubernetes Service (AKS)** cluster with monitoring enabled
- **Azure Managed Grafana** for visualization and dashboards
- **Azure Monitor Workspace (Managed Prometheus)** for metrics collection
- **Azure Automation Account** with PowerShell runbooks for cost optimization
- **Network Security Groups** with appropriate security rules
- **Data Collection Rules (DCRs)** for targeted log collection
- **Azure Monitor Agent (AMA)** deployed on all VMs
- **Auto-shutdown policies** for cost optimization

<img width="1171" height="1177" alt="image" src="https://github.com/user-attachments/assets/4617964d-031f-4e24-a952-2a0c838c6272" />

---

## 📋 Manual Deployment (Optional)

### Prerequisites
- Azure CLI installed and authenticated
- Terraform >= 1.3.0
- Bash shell

### Deploy
```bash
git clone <repository-url>
cd azmon-lab-agents-essentials
chmod +x scripts/deploy-monitoring-viaCLI.sh
./scripts/deploy-monitoring-viaCLI.sh
```

## � Cleanup

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
