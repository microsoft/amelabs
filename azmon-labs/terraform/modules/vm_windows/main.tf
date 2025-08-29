resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  computer_name       = var.computer_name != null ? var.computer_name : var.vm_name
  custom_data         = var.custom_data
  network_interface_ids = [var.nic_id]

  # Patch management
  patch_mode                  = var.patch_mode
  provision_vm_agent         = true
  allow_extension_operations = true
  enable_automatic_updates   = var.enable_automatic_updates

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb        = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_sku
    version   = var.windows_version
  }

  tags = var.tags
}
