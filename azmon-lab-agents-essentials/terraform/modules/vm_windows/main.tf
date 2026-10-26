resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  computer_name         = var.computer_name != null ? var.computer_name : var.vm_name
  custom_data           = var.custom_data
  network_interface_ids = [var.nic_id]

  # System-assigned managed identity for Azure Monitor Agent
  identity {
    type = "SystemAssigned"
  }

  # Patch management
  patch_mode                 = var.patch_mode
  provision_vm_agent         = true
  allow_extension_operations = true
  automatic_updates_enabled  = var.enable_automatic_updates

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_sku
    version   = var.windows_version
  }

  tags = var.tags
}

# Azure Monitor Agent Extension for Windows VM
resource "azurerm_virtual_machine_extension" "ama_windows" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  tags = var.tags
}

# Role assignment for Monitoring Metrics Publisher (minimal required for AMA)
resource "azurerm_role_assignment" "monitoring_metrics_publisher" {
  scope                = azurerm_windows_virtual_machine.vm.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_windows_virtual_machine.vm.identity[0].principal_id
}
