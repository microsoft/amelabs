# vmss_windows/main.tf
resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_E2s_v3"
  instances           = 2
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  computer_name_prefix = "vmsswin"  # Max 9 characters

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-vmss"
    primary = true

    ip_configuration {
      name                                    = "ipconfig"
      subnet_id                               = var.subnet_id
      primary                                 = true
      load_balancer_backend_address_pool_ids = [var.backend_pool_id]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  extension {
    name                       = "AzureMonitorWindowsAgent"
    publisher                  = "Microsoft.Azure.Monitor"
    type                       = "AzureMonitorWindowsAgent"
    auto_upgrade_minor_version = true
    automatic_upgrade_enabled  = true
    type_handler_version       = "1.0"
  }
}

resource "azurerm_role_assignment" "vmss_log_analytics" {
  principal_id         = azurerm_windows_virtual_machine_scale_set.vmss.identity[0].principal_id
  role_definition_name = "Log Analytics Contributor"
  scope                = var.workspace_id
}