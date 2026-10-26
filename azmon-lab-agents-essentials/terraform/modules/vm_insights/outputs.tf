output "data_collection_rule_id" {
  description = "Resource ID of the Data Collection Rule for VM Insights"
  value       = azurerm_monitor_data_collection_rule.vm_insights.id
}

output "data_collection_rule_name" {
  description = "Name of the Data Collection Rule for VM Insights"
  value       = azurerm_monitor_data_collection_rule.vm_insights.name
}

output "vm_insights_installation_status" {
  description = "Status of VM Insights DCR association for each VM"
  value = {
    windows = var.windows_vm_name != null && var.windows_vm_name != "" ? "DCR associated" : "Not configured"
    redhat  = var.redhat_vm_name != null && var.redhat_vm_name != "" ? "DCR associated" : "Not configured"
    ubuntu  = var.ubuntu_vm_name != null && var.ubuntu_vm_name != "" ? "DCR associated" : "Not configured"
  }
}

