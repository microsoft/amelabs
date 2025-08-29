# Azure Monitoring Lab

A comprehensive Azure monitoring lab environment built with Terraform and automated with Bash scripts. This lab deploys a complete monitoring infrastructure including virtual machines, Virtual Machine Scale Sets (VMSS), Log Analytics workspace, Sentinel, Data Collection Rules (DCRs), and Azure Monitor Agent (AMA).

## 🚀 Quick Start (Recommended)

**The easiest way to deploy this lab is using Azure Portal Bash:**

1. Open [Azure Portal](https://portal.azure.com)
2. Click on the **Cloud Shell** icon (terminal icon in the top menu)
3. Select **Bash** when prompted
4. Run this single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/microsoft/amelabs/refs/heads/main/azmon-lab-agents-essentials/init-lab.sh)
```

That's it! ✨ The script will automatically:
- Deploy all Azure resources using Terraform and Az Cli
- Configure monitoring agents and data collection rules
- Set up auto-shutdown policies
- Install simulators and forwarders
- Configure everything for you

The entire deployment takes about 25-30 minutes. You'll be prompted for a few configuration options during the setup.

## 🏗️ Architecture

This lab creates the following Azure resources:

- **Resource Group** with Log Analytics Workspace
- **Windows Virtual Machine Scale Set (VMSS)** for scalable monitoring scenarios
- **Ubuntu VM** with Syslog Data Collection Rule (DCR)
- **Windows VM** for Windows-specific monitoring
- **Red Hat VM** with CEF Data Collection Rule for Sentinel integration
- **Network Security Groups** with appropriate security rules
- **Data Collection Rules (DCRs)** for targeted log collection
- **Azure Monitor Agent (AMA)** deployed on all VMs
- **Auto-shutdown policies** for cost optimization

<img width="1171" height="1177" alt="image" src="https://github.com/user-attachments/assets/4617964d-031f-4e24-a952-2a0c838c6272" />

---

## � Manual Deployment (Optional)

*The following sections are for advanced users who want to manually deploy or customize the lab. For most users, the Quick Start method above is recommended.*

### Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.3.0
- Bash shell (Linux/macOS/WSL)
- jq command-line JSON processor

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd azmon-labs
```

### 2. Configure Variables

Edit the Terraform variables in `terraform/environments/default/terraform.tfvars`:

```hcl
resource_group_name = "rg-azmon-lab"
location = "East US"
workspace_name = "law-azmon-lab"
automation_account_name = "aa-vmss-autoshutdown"  # Azure Automation Account name
# ... other variables
```

### 3. Deploy the Lab

Run the main deployment script:

```bash
chmod +x scripts/deploy-monitoring-viaCLI.sh
./scripts/deploy-monitoring-viaCLI.sh
```

This script will:
1. Initialize and apply Terraform configuration
2. Deploy all Azure resources
3. Extract resource information from Terraform outputs
4. Pass resource parameters to post-deployment script
5. Configure Azure Monitor Agent (AMA) on all VMs
6. Set up Data Collection Rules (DCRs)
7. Install AMA Forwarder on Red Hat VM
8. Install CEF Simulator on Ubuntu VM
9. Configure auto-shutdown for all VMs and VMSS
10. Deploy VMSS auto-shutdown Azure Automation Runbook

**Note**: All scripts now use parameter-based invocation instead of reading from JSON files, making them more robust and automation-friendly.

## 🔧 Script Parameters

### deploy-aks-managedsolutions.sh

The AKS and managed solutions deployment script accepts the following parameters:

```bash
./deploy-aks-managedsolutions.sh <RESOURCE_GROUP> <WORKSPACE_ID> <WORKSPACE_NAME> <AKS_CLUSTER> <MANAGED_GRAFANA> <PROM_NAME>
```

**Parameters:**
- `RESOURCE_GROUP`: Name of the Azure resource group
- `WORKSPACE_ID`: Full resource ID of the Log Analytics workspace
- `WORKSPACE_NAME`: Name of the Log Analytics workspace
- `AKS_CLUSTER`: Name of the AKS cluster
- `MANAGED_GRAFANA`: Name of the Managed Grafana
- `PROM_NAME`: Name of the Azure Monitor Workspace (Managed Prometheus)

**Example:**
```bash
./deploy-aks-managedsolutions.sh "rg-azmon-lab" "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-azmon-lab/providers/Microsoft.OperationalInsights/workspaces/law-azmon-lab" "law-azmon-lab" "aks-cluster-001" "grafana-instance" "prometheus-workspace"
```

### post-deployment-tasks.sh

The post-deployment script accepts the following parameters:

```bash
./post-deployment-tasks.sh <RESOURCE_GROUP> <REDHAT_VM_NAME> <UBUNTU_VM_NAME> <WINDOWS_VM_NAME> <VMSS_NAME> <REDHAT_PRIVATE_IP> <UTC_TIME> <AUTOMATION_ACCOUNT_NAME>
```

**Parameters:**
- `RESOURCE_GROUP`: Name of the Azure resource group
- `REDHAT_VM_NAME`: Name of the Red Hat virtual machine
- `UBUNTU_VM_NAME`: Name of the Ubuntu virtual machine  
- `WINDOWS_VM_NAME`: Name of the Windows virtual machine
- `VMSS_NAME`: Name of the Windows virtual machine scale set
- `REDHAT_PRIVATE_IP`: Private IP address of the Red Hat VM
- `UTC_TIME`: UTC time for auto-shutdown in HHMM format (calculated from user's local 7:00 PM)
- `AUTOMATION_ACCOUNT_NAME`: Name of the Azure Automation Account for VMSS shutdown

**Example:**
```bash
./post-deployment-tasks.sh "rg-azmon-lab" "vm-redhat-001" "vm-ubuntu-001" "vm-windows-001" "vmss-windows-001" "10.0.1.100" "0000" "aa-vmss-autoshutdown"
```

The UTC_TIME parameter represents 7:00 PM in the user's local timezone converted to UTC time. This approach eliminates dependency on JSON file parsing and makes the scripts more portable and testable.

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
```

## 🔍 Verification

After deployment, verify the setup:

### 1. Check Azure Resources

```bash
# List all resources in the resource group
az resource list --resource-group rg-azmon-lab --output table

# Check VM status
az vm list --resource-group rg-azmon-lab --show-details --output table

# Check VMSS status
az vmss list --resource-group rg-azmon-lab --output table
```

### 2. Verify Auto-Shutdown

```bash
# Check auto-shutdown configuration for VMs
az vm show --resource-group rg-azmon-lab --name <vm-name> --query "scheduledEventsProfile"

# Check auto-shutdown for VMSS (via Azure Automation)
az automation account list --resource-group rg-azmon-lab --output table
az automation runbook list --automation-account-name <automation-account-name> --resource-group rg-azmon-lab

# Check Automation Account schedules
az automation schedule list --automation-account-name <automation-account-name> --resource-group rg-azmon-lab
```

### 3. Monitor Logs

- Access Log Analytics workspace in Azure portal
- Check for incoming CEF messages from Red Hat VM
- Verify syslog data from Ubuntu VM
- Monitor Azure Monitor metrics and alerts

## 🛠️ Customization

### Modify Auto-Shutdown Time

The auto-shutdown time is calculated automatically from your local timezone. To change it:

1. Modify the target local time in the main deployment script
2. The script will automatically calculate the corresponding UTC time
3. Both VM auto-shutdown and VMSS Function schedule will be updated accordingly

Alternatively, you can directly modify the UTC hour parameter when calling the scripts manually:

```bash
# For 9:00 PM shutdown (21:00 local time), modify the automation_account_name parameter:
# The schedule is automatically configured based on your local timezone during deployment
```

### Customize VMSS Automation Schedule

The Azure Automation Runbook schedule is automatically configured during deployment based on your local timezone. To modify the schedule manually, you can update the automation account schedule in the Azure portal or via Azure CLI after deployment.

### Customize Automation Account Naming

Modify the Azure Automation Account name in your `terraform.tfvars`:

```hcl
automation_account_name = "mycompany-aa-autoshutdown"  # Azure Automation Account name
```

**Requirements:**
- **Automation Account Name**: Maximum 50 characters, letters, numbers, and hyphens only
- Must be unique within your Azure region and resource group

### Add Custom Data Collection Rules

Create new DCR modules in `terraform/modules/` and reference them in `main.tf`.

### Extend VM Configurations

Modify the VM modules to add:
- Additional extensions
- Custom scripts
- Different VM sizes
- Additional disks

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy -var-file="environments/default/terraform.tfvars"
```

## 🔧 Troubleshooting

### Common Issues

1. **Auto-shutdown not working**: Check timezone detection and Azure CLI authentication
2. **DCR association failures**: Verify AMA is properly installed and identity configured
3. **Network connectivity**: Check NSG rules and public IP assignments
4. **Log forwarding issues**: Verify rsyslog configuration and network connectivity
5. **VMSS Automation deployment failures**: Check Azure Automation Account creation and managed identity permissions
6. **Runbook execution issues**: Verify the Automation Account has Contributor role on the VMSS resource group
7. **Schedule not triggering**: Check the automation schedule configuration and timezone settings
8. **Automation account naming conflicts**: Ensure your automation account name is unique in the region

### Debug Commands

```bash
# Check Terraform outputs
terraform output -json

# Verify Azure CLI login
az account show

# Check VM extensions
az vm extension list --resource-group rg-azmon-lab --vm-name <vm-name>

# Check Azure Automation Account status
az automation account list --resource-group rg-azmon-lab --output table

# Check automation runbooks
az automation runbook list --automation-account-name <automation-account-name> --resource-group rg-azmon-lab

# Check automation schedules
az automation schedule list --automation-account-name <automation-account-name> --resource-group rg-azmon-lab

# View automation job status
az automation job list --automation-account-name <automation-account-name> --resource-group rg-azmon-lab

# View systemd logs (on VMs)
sudo journalctl -u rsyslog -f

# Test VMSS shutdown runbook manually
az automation runbook start --automation-account-name <automation-account-name> --resource-group rg-azmon-lab --name <runbook-name>
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Azure documentation for specific services
3. Open an issue in the repository
