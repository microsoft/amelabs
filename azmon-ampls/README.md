# Azure Monitor AMPLS Lab Environment

This comprehensive lab demonstrates Azure Monitor Private Link Scope (AMPLS) implementation with a hub-and-spoke network topology, featuring:

- **Hub-and-Spoke Network Architecture**: Central hub VNet with Windows, Ubuntu, and App Service spoke VNets
- **Azure Monitor Private Link Scope**: Private-only ingestion and query for monitoring data  
- **Multi-Platform Applications**: Java, .NET, and Node.js web applications on App Service
- **Virtual Machine Monitoring**: Windows and Ubuntu VMs with Azure Monitor Agent
- **Interactive Setup**: User-friendly deployment script with guided configuration

## Architecture Overview

<img width="1341" height="1638" alt="image" src="https://github.com/user-attachments/assets/3121767c-1dd6-4d6e-9df3-1e359d0f20e4" />


```
┌──────────────────────────────────────────────────────────────┐
│                        Hub VNet                              │
│                    (10.0.0.0/16)                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              ampls-subnet                               │ │
│  │          [AMPLS Private Endpoints]                      │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────┬───────────────────────┬──────────────────│─────┘
              │                       │                  │
       ┌──────┴────────┐       ┌──────┴────────┐       ┌─│───────────────┐
       │ Windows Spoke │       │ Ubuntu Spoke  │       │ App Service     │
       │     VNet      │       │     VNet      │       │    Spoke VNet   │
       │ (10.1.0.0/16) │       │ (10.2.0.0/16) │       │ (10.3.0.0/16)   │
       │               │       │               │       │                 │
       │ [Windows VM]  │       │ [Ubuntu VM]   │       │ [App Service    │
       │               │       │               │       │  Integration]   │
       └───────────────┘       └───────────────┘       └─────────────────┘
```

## Prerequisites

- Azure CLI installed and configured
- Terraform 1.0+ installed
- Appropriate Azure permissions to create resources

## Quick Start

### Interactive Deployment (Recommended)

1. **Clone the repository and navigate to project root**:
   ```bash
   git clone https://github.com/tiagojfernandes/azmon-ampls.git
   cd azmon-ampls
   ```

2. **Run the interactive setup script**:
   ```bash
   # The script will guide you through configuration
   ./init-lab.sh
   ```

   The script will prompt you for:
   - Resource Group name
   - Azure region
   - Log Analytics Workspace name  
   - Timezone for VMs
   - VM administrator password

3. **Wait for deployment to complete**:
   - Infrastructure provisioning (~15-20 minutes)
   - Application deployment (~5-10 minutes)

### Manual Deployment

If you prefer manual deployment:

1. **Navigate to the production environment**:
   ```bash
   cd environments/prod
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Create and customize terraform.tfvars**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
   ```

4. **Plan and deploy**:
   ```bash
   terraform plan
   terraform apply
   ```

5. **Deploy applications separately**:
   ```bash
   # From project root
   cd scripts
   ./install-appservice-java.sh <resource_group> <webapp_name> <app_service_plan>
   ./install-appservice-dotnet.sh <resource_group> <webapp_name> <app_service_plan>
   ./install-appservice-nodejs.sh <resource_group> <webapp_name> <app_service_plan>
   ```

## Configuration Details

### Network Architecture

**Hub-and-Spoke Topology**:
- **Hub VNet**: Central network containing AMPLS private endpoints
- **Windows Spoke VNet**: Peered to hub, contains Windows Server 2022 VM
- **Ubuntu Spoke VNet**: Peered to hub, contains Ubuntu 22.04 LTS VM  
- **App Service Spoke VNet**: Peered to hub, provides VNet integration for App Service applications
- **VNet Peering**: Bidirectional peering between hub and all three spoke VNets

**Architectural Benefits**:
- **Separation of Concerns**: Dedicated spoke VNet for App Service provides network isolation
- **Scalability**: App Service spoke can be expanded independently without affecting other workloads
- **Security**: Network segmentation reduces blast radius and allows granular network policies
- **Flexibility**: Future App Services can leverage the same spoke VNet infrastructure

### App Service Applications

Three web applications are deployed to demonstrate different technology stacks:

1. **Java Application**: Spring Boot application with Application Insights integration
2. **.NET Application**: ASP.NET Core application with telemetry collection
3. **Node.js Application**: Express.js application with custom metrics

All applications:
- Use VNet integration with the dedicated App Service spoke VNet
- Access Azure Monitor services through VNet peering to hub with AMPLS private endpoints
- Send telemetry through private endpoints only
- Connect to the same Application Insights resource

### Azure Monitor Private Link Service (AMPLS)

The AMPLS is configured with:
- **Ingestion Access Mode**: PrivateOnly - only accepts data from private networks
- **Query Access Mode**: PrivateOnly - only allows queries from private networks
- **Private Endpoints**: Deployed in hub VNet for Log Analytics and Application Insights
- **DNS Configuration**: Private DNS zones for proper name resolution

### Log Analytics Workspace

The workspace is configured with:
- **Custom Naming**: User-provided workspace name during setup
- **Internet Ingestion**: Disabled (enforces private link only)
- **Internet Query**: Disabled (enforces private link only)
- **Retention**: 30 days
- **SKU**: PerGB2018

### Virtual Machine Configuration

Both VMs are automatically configured with:
- **Azure Monitor Agent**: Latest version with auto-upgrade enabled
- **Custom Applications**: 
  - Windows VM: .NET application with performance counters
  - Ubuntu VM: Python Flask applications for load simulation
- **Data Collection Rules**: Performance counters and event logs
- **Network Security Groups**: RDP (Windows) and SSH (Ubuntu) access

## Testing the Environment

### 1. Verify Application Deployment

**Check App Service Applications**:
```bash
# Get the App Service URLs from Terraform output
cd environments/prod
terraform output app_service_urls

# Test each application
curl https://<java-app-url>/actuator/health
curl https://<dotnet-app-url>/health
curl https://<nodejs-app-url>/health
```

### 2. Verify Private Connectivity

Connect to either VM and test DNS resolution:

**Windows VM** (PowerShell):
```powershell
# Test Azure Monitor endpoint resolution
nslookup oms.opinsights.azure.com
nslookup dc.services.visualstudio.com

# Check if endpoints resolve to private IPs (10.x.x.x range)
# Should NOT resolve to public IPs when AMPLS is working correctly
```

**Ubuntu VM** (Bash):
```bash
# Test Azure Monitor endpoint resolution  
dig oms.opinsights.azure.com
dig dc.services.visualstudio.com

# Check if endpoints resolve to private IPs (10.x.x.x range)
```

### 3. Verify Data Ingestion

In the Azure Portal:
1. Navigate to the Log Analytics Workspace
2. Go to Logs section
3. Run queries to verify data ingestion:

```kql
// Check for performance data from VMs
Perf
| where TimeGenerated > ago(1h)
| summarize count() by Computer, CounterName

// Check for Application Insights data
AppRequests
| where TimeGenerated > ago(1h)  
| summarize count() by AppRoleName, Name

// Check for custom events from applications
AppCustomEvents
| where TimeGenerated > ago(1h)
| summarize count() by AppRoleName, Name

// Check VM heartbeats
Heartbeat
| where TimeGenerated > ago(1h)
| summarize count() by Computer, OSType
```

### 4. Verify Private Link Status

Check the AMPLS configuration:
1. Navigate to Azure Monitor Private Link Scope in the portal
2. Verify connected resources show both Log Analytics Workspace and Application Insights
3. Check private endpoint connections are approved and connected
4. Confirm all DNS zones are properly linked to VNets

## Deployed Resources

After successful deployment, you'll have:

### Infrastructure
- **4 Virtual Networks**: Hub + 3 spoke VNets with peering (Windows, Ubuntu, App Service)
- **2 Virtual Machines**: Windows Server 2022 and Ubuntu 22.04 LTS
- **1 App Service Plan**: Linux-based hosting 3 web applications
- **1 Log Analytics Workspace**: With custom name and private-only access
- **1 Application Insights**: Connected to AMPLS for private telemetry
- **1 Azure Monitor Private Link Scope**: With private endpoints

### Applications  
- **Java Spring Boot App**: Runs on Java 17 with actuator endpoints
- **.NET Core App**: ASP.NET Core 8.0 with health checks
- **Node.js App**: Express.js with custom metrics and monitoring

### Monitoring Configuration
- **Azure Monitor Agents**: On both VMs with data collection rules
- **VM Extensions**: Custom scripts for application installation  
- **Private DNS Zones**: For Azure Monitor endpoints resolution

## Customization

### Variables

Key variables you can customize in `environments/prod/terraform.tfvars`:

```hcl
# Basic settings - will be prompted during interactive setup
resource_group_name         = "rg-ampls-lab"
location                   = "East US"
log_analytics_workspace_name = "law-my-workspace"
timezone                   = "Eastern Standard Time"  # Windows timezone
admin_password             = "YourStrongP@ssw0rd!"

# Advanced settings (optional customization)
prefix = "azmon"
vm_size = "Standard_B2ms"

# Network settings (hub-and-spoke topology)
hub_vnet_address_space                    = ["10.0.0.0/16"]
windows_spoke_vnet_address_space          = ["10.1.0.0/16"] 
ubuntu_spoke_vnet_address_space           = ["10.2.0.0/16"]
appservice_spoke_vnet_address_space       = ["10.3.0.0/16"]
hub_ampls_subnet_address_prefixes         = ["10.0.1.0/24"]
appservice_spoke_integration_subnet_address_prefixes = ["10.3.1.0/24"]
windows_spoke_vm_subnet_address_prefixes  = ["10.1.1.0/24"]
ubuntu_spoke_vm_subnet_address_prefixes   = ["10.2.1.0/24"]

# Tags
tags = {
  Environment = "Lab"
  Project     = "Azure Monitor AMPLS"
  Owner       = "Your Name"
}
```

### Script Customization

The deployment includes modular scripts in the `scripts/` directory:

- **`init-lab.sh`**: Main orchestration script with user prompts
- **`install-appservice-java.sh`**: Deploys Spring Boot application
- **`install-appservice-dotnet.sh`**: Deploys ASP.NET Core application  
- **`install-appservice-nodejs.sh`**: Deploys Express.js application
- **`install-dotnet-app-winvm.ps1`**: Windows VM application setup
- **`install-python-apps-linuxvm.sh`**: Ubuntu VM application setup

### Adding New Environments

To create additional environments (e.g., dev, staging):

1. **Create a new environment directory**:
   ```bash
   mkdir environments/dev
   ```

2. **Copy the prod configuration**:
   ```bash
   cp environments/prod/* environments/dev/
   ```

3. **Customize variables** for the new environment in `environments/dev/terraform.tfvars`

### Module Customization

Each module can be customized independently:

- **Network Module**: Modify subnet ranges, add additional subnets, or configure different NSG rules
- **Monitor Module**: Adjust data collection rules, add more performance counters, or configure different retention policies  
- **Compute Module**: Change VM sizes, add more VMs, or use different OS images

## Security Considerations

### Production Recommendations

1. **Remove Public IPs**: After initial setup, remove public IPs and use Azure Bastion or VPN
2. **Implement Azure Firewall**: Add Azure Firewall for outbound filtering
3. **Use Managed Identity**: Configure VMs with managed identities instead of passwords
4. **Network Segmentation**: Implement additional subnets and NSGs for micro-segmentation
5. **Key Vault**: Store VM passwords and certificates in Azure Key Vault

### Current Security Features

- Network Security Groups with minimal required access
- Private-only Azure Monitor access
- Strong random passwords for VMs
- Latest OS images with security updates

## Troubleshooting

### Common Issues

1. **Agent Not Reporting Data**:
   - Check Data Collection Rule associations
   - Verify private endpoint DNS resolution
   - Check NSG rules allow outbound HTTPS (443)

2. **DNS Resolution Issues**:
   - Verify private DNS zone links to both VNets
   - Check VNet peering is properly configured
   - Restart VMs if DNS cache is stale

3. **Private Endpoint Connection**:
   - Ensure private endpoint network policies are disabled
   - Check subnet has sufficient IP addresses
   - Verify AMPLS configuration

### Useful Commands

```bash
# Navigate to production environment
cd environments/prod

# Check Terraform state
terraform state list

# View specific resource
terraform state show module.monitor.azurerm_monitor_private_link_scope.main

# Force recreation of problematic resource
terraform taint module.network.azurerm_virtual_network_peering.hub_to_spoke
terraform apply

# Get sensitive outputs
terraform output -json | jq '.vm_admin_password.value'
```

## Cleanup

To destroy all resources:

```bash
cd environments/prod
terraform destroy
```

**Warning**: This will permanently delete all resources created by this configuration.

## Cost Considerations

### Estimated Monthly Costs (East US pricing)

- **Virtual Machines**: ~$60-120/month (depending on size and runtime)
- **Log Analytics Workspace**: ~$2.30/GB ingested + $0.10/GB retention
- **Private Endpoints**: ~$7.20/month per endpoint
- **VNet Peering**: ~$0.01/GB transferred
- **Public IPs**: ~$3.65/month per IP

### Cost Optimization Tips

1. **Auto-shutdown**: Enable auto-shutdown for VMs during non-testing hours
2. **Smaller VM SKUs**: Use B1s for minimal testing requirements
3. **Reduce Retention**: Lower Log Analytics retention period
4. **Remove Public IPs**: Use Azure Bastion or VPN instead

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for improvements.

## License

This project is provided as-is for educational and testing purposes.
