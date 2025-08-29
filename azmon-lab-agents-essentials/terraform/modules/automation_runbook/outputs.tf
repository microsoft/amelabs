# automation_runbook/outputs.tf

output "automation_account_id" {
  description = "ID of the Azure Automation Account"
  value       = azurerm_automation_account.automation.id
}

output "automation_account_name" {
  description = "Name of the Azure Automation Account"
  value       = azurerm_automation_account.automation.name
}

output "runbook_name" {
  description = "Name of the VMSS shutdown runbook"
  value       = azurerm_automation_runbook.vmss_shutdown.name
}

output "schedule_name" {
  description = "Name of the shutdown schedule"
  value       = azurerm_automation_schedule.vmss_shutdown_schedule.name
}

output "managed_identity_principal_id" {
  description = "Principal ID of the automation account's managed identity"
  value       = azurerm_automation_account.automation.identity[0].principal_id
}
