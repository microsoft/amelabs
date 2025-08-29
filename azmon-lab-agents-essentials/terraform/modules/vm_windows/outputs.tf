# VM Basic Information
output "vm_id" {
  description = "The ID of the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.id
}

output "vm_name" {
  description = "The name of the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.name
}

output "vm_size" {
  description = "The size of the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.size
}

# Network Information
output "private_ip_address" {
  description = "The private IP address of the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.public_ip_address
}

output "network_interface_ids" {
  description = "The network interface IDs attached to the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.network_interface_ids
}

# OS and Image Information
output "os_disk" {
  description = "The OS disk configuration of the Windows Virtual Machine"
  value = {
    name                 = azurerm_windows_virtual_machine.vm.os_disk[0].name
    size_gb             = azurerm_windows_virtual_machine.vm.os_disk[0].disk_size_gb
    caching             = azurerm_windows_virtual_machine.vm.os_disk[0].caching
    storage_account_type = azurerm_windows_virtual_machine.vm.os_disk[0].storage_account_type
  }
}

output "source_image_reference" {
  description = "The source image reference used for the Windows Virtual Machine"
  value = {
    publisher = azurerm_windows_virtual_machine.vm.source_image_reference[0].publisher
    offer     = azurerm_windows_virtual_machine.vm.source_image_reference[0].offer
    sku       = azurerm_windows_virtual_machine.vm.source_image_reference[0].sku
    version   = azurerm_windows_virtual_machine.vm.source_image_reference[0].version
  }
}

# Authentication Information
output "admin_username" {
  description = "The admin username for the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.admin_username
}

# Location and Resource Group
output "location" {
  description = "The location where the Windows Virtual Machine is deployed"
  value       = azurerm_windows_virtual_machine.vm.location
}

output "resource_group_name" {
  description = "The resource group name where the Windows Virtual Machine is deployed"
  value       = azurerm_windows_virtual_machine.vm.resource_group_name
}

# Additional Useful Information
output "tags" {
  description = "The tags assigned to the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.tags
}

output "vm_computer_name" {
  description = "The computer name of the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm.computer_name
}

# Connection Information
output "rdp_connection_info" {
  description = "RDP connection information for the Windows Virtual Machine"
  value = {
    public_ip = azurerm_windows_virtual_machine.vm.public_ip_address
    username  = azurerm_windows_virtual_machine.vm.admin_username
    port      = 3389
  }
}
