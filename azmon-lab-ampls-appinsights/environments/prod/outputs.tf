output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "data_collection_rule_name" {
  description = "Name of the Data Collection Rule"
  value       = module.monitor.data_collection_rule_name
}

output "ubuntu_data_collection_rule_name" {
  description = "Name of the Ubuntu Data Collection Rule"
  value       = module.monitor.ubuntu_data_collection_rule_name
}

output "data_collection_endpoint_name" {
  description = "Name of the Data Collection Endpoint"
  value       = module.monitor.data_collection_endpoint_name
}

# Application Insights outputs
output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = module.monitor.application_insights_name
}

output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = module.monitor.application_insights_id
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitor.connection_string
  sensitive   = true
}

# Network outputs
output "hub_vnet_name" {
  description = "Name of the hub virtual network"
  value       = module.network.hub_vnet_name
}

output "windows_spoke_vnet_name" {
  description = "Name of the Windows spoke virtual network"
  value       = module.network.windows_spoke_vnet_name
}

output "ubuntu_spoke_vnet_name" {
  description = "Name of the Ubuntu spoke virtual network"
  value       = module.network.ubuntu_spoke_vnet_name
}

# Monitor outputs
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = module.monitor.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = module.monitor.log_analytics_workspace_name
}

output "ampls_name" {
  description = "Name of the Azure Monitor Private Link Scope"
  value       = module.monitor.ampls_name
}

output "private_endpoint_ip" {
  description = "Private IP address of the AMPLS private endpoint"
  value       = module.monitor.private_endpoint_ip
}

# Compute outputs
output "windows_vm_name" {
  description = "Name of the Windows VM"
  value       = module.compute.windows_vm_name
}

output "ubuntu_vm_name" {
  description = "Name of the Ubuntu VM"
  value       = module.compute.ubuntu_vm_name
}

output "windows_vm_public_ip" {
  description = "Public IP address of the Windows VM"
  value       = module.compute.windows_vm_public_ip
}

output "ubuntu_vm_public_ip" {
  description = "Public IP address of the Ubuntu VM"
  value       = module.compute.ubuntu_vm_public_ip
}

output "windows_vm_private_ip" {
  description = "Private IP address of the Windows VM"
  value       = module.compute.windows_vm_private_ip
}

output "ubuntu_vm_private_ip" {
  description = "Private IP address of the Ubuntu VM"
  value       = module.compute.ubuntu_vm_private_ip
}

output "vm_admin_username" {
  description = "Admin username for VMs"
  value       = var.admin_username
}

output "vm_admin_password" {
  description = "Admin password for VMs"
  value       = module.compute.vm_admin_password
  sensitive   = true
}

# Auto-shutdown outputs
output "autoshutdown_enabled" {
  description = "Whether auto-shutdown is enabled for VMs"
  value       = var.enable_autoshutdown
}

output "autoshutdown_time" {
  description = "Daily auto-shutdown time (UTC)"
  value       = var.enable_autoshutdown ? "${var.autoshutdown_time} ${var.autoshutdown_timezone}" : "Disabled"
}

output "windows_vm_autoshutdown_schedule_id" {
  description = "ID of the Windows VM auto-shutdown schedule"
  value       = module.compute.windows_vm_autoshutdown_schedule_id
}

output "ubuntu_vm_autoshutdown_schedule_id" {
  description = "ID of the Ubuntu VM auto-shutdown schedule"
  value       = module.compute.ubuntu_vm_autoshutdown_schedule_id
}

# App Service outputs
output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = module.appservice.plan_name
}

output "java_webapp_name" {
  description = "Name of the Java web app"
  value       = module.appservice.java_webapp_name
}

output "dotnet_webapp_name" {
  description = "Name of the .NET web app"
  value       = module.appservice.dotnet_webapp_name
}

output "node_webapp_name" {
  description = "Name of the Node.js web app"
  value       = module.appservice.node_webapp_name
}

output "java_webapp_id" {
  description = "ID of the Java web app"
  value       = module.appservice.java_webapp_id
}

output "dotnet_webapp_id" {
  description = "ID of the .NET web app"
  value       = module.appservice.dotnet_webapp_id
}

output "node_webapp_id" {
  description = "ID of the Node.js web app"
  value       = module.appservice.node_webapp_id
}
