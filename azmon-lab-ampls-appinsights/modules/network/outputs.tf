output "hub_vnet_id" {
  description = "ID of the hub virtual network"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the hub virtual network"
  value       = azurerm_virtual_network.hub.name
}

output "windows_spoke_vnet_id" {
  description = "ID of the Windows spoke virtual network"
  value       = azurerm_virtual_network.windows_spoke.id
}

output "windows_spoke_vnet_name" {
  description = "Name of the Windows spoke virtual network"
  value       = azurerm_virtual_network.windows_spoke.name
}

output "ubuntu_spoke_vnet_id" {
  description = "ID of the Ubuntu spoke virtual network"
  value       = azurerm_virtual_network.ubuntu_spoke.id
}

output "ubuntu_spoke_vnet_name" {
  description = "Name of the Ubuntu spoke virtual network"
  value       = azurerm_virtual_network.ubuntu_spoke.name
}

output "appservice_spoke_vnet_id" {
  description = "ID of the App Service spoke virtual network"
  value       = azurerm_virtual_network.appservice_spoke.id
}

output "appservice_spoke_vnet_name" {
  description = "Name of the App Service spoke virtual network"
  value       = azurerm_virtual_network.appservice_spoke.name
}

output "hub_ampls_subnet_id" {
  description = "ID of the AMPLS subnet in hub VNet"
  value       = azurerm_subnet.hub_ampls.id
}

output "windows_spoke_vm_subnet_id" {
  description = "ID of the VM subnet in Windows spoke VNet"
  value       = azurerm_subnet.windows_spoke_vms.id
}

output "ubuntu_spoke_vm_subnet_id" {
  description = "ID of the VM subnet in Ubuntu spoke VNet"
  value       = azurerm_subnet.ubuntu_spoke_vms.id
}

output "vm_nsg_id" {
  description = "ID of the VM network security group"
  value       = azurerm_network_security_group.vm_nsg.id
}

# App Service integration subnet in App Service spoke VNet
output "appservice_integration_subnet_id" {
  description = "ID of the App Service integration subnet in App Service spoke VNet"
  value       = azurerm_subnet.appservice_spoke_integration.id
}