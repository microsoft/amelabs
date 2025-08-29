# terraform/outputs.tf

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "log_analytics_workspace_id" {
  description = "The full resource ID of the Log Analytics Workspace"
  value       = module.log_analytics.workspace_id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = module.log_analytics.workspace_name
}

output "user_timezone" {
  description = "The user's timezone for auto-shutdown configuration"
  value       = var.user_timezone
}


# VM Names
output "ubuntu_vm_name" {
  description = "The name of the Ubuntu Virtual Machine"
  value       = module.vm_ubuntu.vm_name
}

output "windows_vm_name" {
  description = "The name of the Windows Virtual Machine"
  value       = module.vm_windows.vm_name
}

output "redhat_vm_name" {
  description = "The name of the Red Hat Virtual Machine"
  value       = module.vm_redhat.vm_name
}

output  "aks_name" {
  description = "AKS Cluster name"
  value       = var.aks_name
}

output  "grafana_name" {
  description = "Managed Grafana name"
  value       = var.grafana_name
}

output  "prom_name" {
  description = "Managed Prometheus name"
  value       = var.prom_name
}

# VM IP Addresses
output "redhat_vm_private_ip" {
  description = "The private (internal) IP address of the Red Hat Virtual Machine"
  value       = module.vm_redhat.private_ip_address
}

output "vmss_name" {
  description = "The name of the Windows Virtual Machine Scale Set"
  value       = module.vmss_windows.vmss_name
}

output "automation_account_name" {
  description = "The name of the Azure Automation Account"
  value       = module.automation_runbook.automation_account_name
}

output "automation_runbook_name" {
  description = "The name of the VMSS shutdown runbook"
  value       = module.automation_runbook.runbook_name
}

output "automation_schedule_name" {
  description = "The name of the shutdown schedule"
  value       = module.automation_runbook.schedule_name
}

# VM Insights Outputs
output "vm_insights_data_collection_rule_id" {
  description = "Resource ID of the Data Collection Rule for VM Insights"
  value       = module.vm_insights.data_collection_rule_id
}

output "vm_insights_data_collection_rule_name" {
  description = "Name of the Data Collection Rule for VM Insights"
  value       = module.vm_insights.data_collection_rule_name
}

output "vm_insights_user_assigned_identity_id" {
  description = "Resource ID of the User Assigned Managed Identity for VM Insights"
  value       = module.vm_insights.user_assigned_identity_id
}

output "vm_insights_installation_status" {
  description = "Status of VM Insights installation for all VMs (DCR associations managed by Install-VMInsights.ps1)"
  value       = module.vm_insights.vm_insights_installation_status
}


