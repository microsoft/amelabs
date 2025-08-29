output "windows_vm_id" {
  description = "ID of the Windows VM"
  value       = azurerm_windows_virtual_machine.windows_vm.id
}

output "windows_vm_name" {
  description = "Name of the Windows VM"
  value       = azurerm_windows_virtual_machine.windows_vm.name
}

output "ubuntu_vm_id" {
  description = "ID of the Ubuntu VM"
  value       = azurerm_linux_virtual_machine.ubuntu_vm.id
}

output "ubuntu_vm_name" {
  description = "Name of the Ubuntu VM"
  value       = azurerm_linux_virtual_machine.ubuntu_vm.name
}

output "windows_vm_public_ip" {
  description = "Public IP address of the Windows VM"
  value       = var.enable_public_ips ? azurerm_public_ip.windows_vm_pip[0].ip_address : null
}

output "ubuntu_vm_public_ip" {
  description = "Public IP address of the Ubuntu VM"
  value       = var.enable_public_ips ? azurerm_public_ip.ubuntu_vm_pip[0].ip_address : null
}

output "windows_vm_private_ip" {
  description = "Private IP address of the Windows VM"
  value       = azurerm_network_interface.windows_vm_nic.private_ip_address
}

output "ubuntu_vm_private_ip" {
  description = "Private IP address of the Ubuntu VM"
  value       = azurerm_network_interface.ubuntu_vm_nic.private_ip_address
}

output "vm_admin_password" {
  description = "Admin password for VMs"
  value       = var.admin_password != null ? var.admin_password : random_password.vm_password.result
  sensitive   = true
}

output "windows_vm_identity_principal_id" {
  description = "Principal ID of the Windows VM system-assigned managed identity"
  value       = azurerm_windows_virtual_machine.windows_vm.identity[0].principal_id
}

output "ubuntu_vm_identity_principal_id" {
  description = "Principal ID of the Ubuntu VM system-assigned managed identity"
  value       = azurerm_linux_virtual_machine.ubuntu_vm.identity[0].principal_id
}

output "windows_vm_autoshutdown_schedule_id" {
  description = "ID of the Windows VM auto-shutdown schedule"
  value       = var.enable_autoshutdown ? azurerm_dev_test_global_vm_shutdown_schedule.windows_vm_shutdown[0].id : null
}

output "ubuntu_vm_autoshutdown_schedule_id" {
  description = "ID of the Ubuntu VM auto-shutdown schedule"
  value       = var.enable_autoshutdown ? azurerm_dev_test_global_vm_shutdown_schedule.ubuntu_vm_shutdown[0].id : null
}
