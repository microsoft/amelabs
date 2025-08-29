# automation_runbook/main.tf

# Create Azure Automation Account
resource "azurerm_automation_account" "automation" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Purpose = "VMSS and AKS Auto-shutdown"
  }
}

# Create the PowerShell runbook
resource "azurerm_automation_runbook" "vmss_shutdown" {
  name                    = "stopvmss"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  log_verbose             = true
  log_progress            = true
  description             = "PowerShell runbook to stop VMSS and AKS cluster at scheduled time"
  runbook_type            = "PowerShell"
  content                 = file("${path.module}/scripts/deploy-vmss-aks-shutdown.ps1")

  tags = {
    Purpose = "VMSS and AKS Auto-shutdown"
  }
}

# Note: PowerShell modules will be installed automatically when the runbook runs
# This is more reliable than pre-installing them via Terraform
# The Connect-AzAccount and Get-AzVmss cmdlets will trigger automatic module installation

# Assign Contributor role to the automation account's managed identity for the resource group
resource "azurerm_role_assignment" "automation_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.automation.identity[0].principal_id
}

# Create schedule for the runbook (daily at 19:00 in user's timezone)
resource "azurerm_automation_schedule" "vmss_shutdown_schedule" {
  name                    = "VMSS-Daily-Shutdown"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  frequency               = "Day"
  interval                = 1
  timezone                = "UTC"
  start_time              = "${formatdate("YYYY-MM-DD", timestamp())}T${var.user_timezone_hour}:00Z"
  description             = "Daily schedule to shutdown VMSS at 19:00 in user timezone"

  # Ensure the start time is in the future
  lifecycle {
    ignore_changes = [start_time]
  }
}

# Link the runbook to the schedule
resource "azurerm_automation_job_schedule" "vmss_shutdown_job" {
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  schedule_name           = azurerm_automation_schedule.vmss_shutdown_schedule.name
  runbook_name            = azurerm_automation_runbook.vmss_shutdown.name

  parameters = {
    resourcegroupname = var.resource_group_name
    vmssname          = var.vmss_name
    subscriptionid    = var.subscription_id
    aksname           = var.aks_name
  }

  depends_on = [
    azurerm_role_assignment.automation_contributor
  ]
}
