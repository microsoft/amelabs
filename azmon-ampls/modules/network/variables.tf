variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Address space for the hub virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "windows_spoke_vnet_address_space" {
  description = "Address space for the Windows spoke virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "ubuntu_spoke_vnet_address_space" {
  description = "Address space for the Ubuntu spoke virtual network"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "appservice_spoke_vnet_address_space" {
  description = "Address space for the App Service spoke virtual network"
  type        = list(string)
  default     = ["10.3.0.0/16"]
}

variable "hub_ampls_subnet_address_prefixes" {
  description = "Address prefixes for the AMPLS subnet in hub VNet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "windows_spoke_vm_subnet_address_prefixes" {
  description = "Address prefixes for the VM subnet in Windows spoke VNet"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "ubuntu_spoke_vm_subnet_address_prefixes" {
  description = "Address prefixes for the VM subnet in Ubuntu spoke VNet"
  type        = list(string)
  default     = ["10.2.1.0/24"]
}

variable "appservice_spoke_integration_subnet_address_prefixes" {
  description = "Address prefixes for the App Service integration subnet in App Service spoke VNet"
  type        = list(string)
  default     = ["10.3.1.0/24"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
