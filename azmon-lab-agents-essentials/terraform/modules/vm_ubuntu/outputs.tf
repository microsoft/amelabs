# VM Basic Information
output "vm_id" {
  description = "The ID of the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "The name of the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_size" {
  description = "The size of the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.size
}

# Network Information
output "private_ip_address" {
  description = "The private IP address of the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "network_interface_ids" {
  description = "The network interface IDs attached to the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.network_interface_ids
}

# OS and Image Information
output "os_disk" {
  description = "The OS disk configuration of the Ubuntu Virtual Machine"
  value = {
    name                 = azurerm_linux_virtual_machine.vm.os_disk[0].name
    size_gb             = azurerm_linux_virtual_machine.vm.os_disk[0].disk_size_gb
    caching             = azurerm_linux_virtual_machine.vm.os_disk[0].caching
    storage_account_type = azurerm_linux_virtual_machine.vm.os_disk[0].storage_account_type
  }
}

output "source_image_reference" {
  description = "The source image reference used for the Ubuntu Virtual Machine"
  value = {
    publisher = azurerm_linux_virtual_machine.vm.source_image_reference[0].publisher
    offer     = azurerm_linux_virtual_machine.vm.source_image_reference[0].offer
    sku       = azurerm_linux_virtual_machine.vm.source_image_reference[0].sku
    version   = azurerm_linux_virtual_machine.vm.source_image_reference[0].version
  }
}

# Authentication Information
output "admin_username" {
  description = "The admin username for the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.admin_username
}

# Location and Resource Group
output "location" {
  description = "The location where the Ubuntu Virtual Machine is deployed"
  value       = azurerm_linux_virtual_machine.vm.location
}

output "resource_group_name" {
  description = "The resource group name where the Ubuntu Virtual Machine is deployed"
  value       = azurerm_linux_virtual_machine.vm.resource_group_name
}

# Additional Useful Information
output "tags" {
  description = "The tags assigned to the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.tags
}

output "vm_computer_name" {
  description = "The computer name of the Ubuntu Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.computer_name
}

# Connection Information
output "ssh_connection_command" {
  description = "SSH connection command for the Ubuntu Virtual Machine"
  value       = "ssh ${azurerm_linux_virtual_machine.vm.admin_username}@${azurerm_linux_virtual_machine.vm.public_ip_address}"
}

# Managed Identity Information
output "managed_identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

output "managed_identity_tenant_id" {
  description = "The tenant ID of the system-assigned managed identity"
  value       = azurerm_linux_virtual_machine.vm.identity[0].tenant_id
}