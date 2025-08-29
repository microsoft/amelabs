output "data_collection_rule_id" {
  description = "Resource ID of the Data Collection Rule for VM Insights"
  value       = azurerm_monitor_data_collection_rule.vm_insights.id
}

output "data_collection_rule_name" {
  description = "Name of the Data Collection Rule for VM Insights"
  value       = azurerm_monitor_data_collection_rule.vm_insights.name
}

output "user_assigned_identity_id" {
  description = "Resource ID of the User Assigned Managed Identity for VM Insights"
  value       = azurerm_user_assigned_identity.vm_insights.id
}

output "user_assigned_identity_name" {
  description = "Name of the User Assigned Managed Identity for VM Insights"
  value       = azurerm_user_assigned_identity.vm_insights.name
}

output "vm_insights_installation_status" {
  description = "Status of VM Insights installation for supported VMs (includes DCR associations managed by Install-VMInsights.ps1)"
  value = {
    windows = var.windows_vm_name != null && var.windows_vm_name != "" ? "Configured via Install-VMInsights.ps1 script (includes DCR association)" : "Not configured"
    redhat  = var.redhat_vm_name != null && var.redhat_vm_name != "" ? "Configured via Install-VMInsights.ps1 script (includes DCR association)" : "Not configured"
    ubuntu  = "Skipped - Dependency Agent not supported for this Ubuntu OS version"
  }
}
