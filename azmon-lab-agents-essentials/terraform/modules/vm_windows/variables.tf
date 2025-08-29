# VM Basic Configuration
variable "vm_name" {
  description = "Name of the Windows virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the VM will be created"
  type        = string
}

variable "location" {
  description = "Azure region where the VM will be deployed"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine (e.g., Standard_B2s, Standard_D2s_v3)"
  type        = string
  default     = "Standard_B2s"
}

# Authentication Configuration
variable "admin_username" {
  description = "Administrator username for the VM"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Administrator password for the VM"
  type        = string
  sensitive   = true
}

# Network Configuration
variable "nic_id" {
  description = "ID of the network interface to attach to the VM"
  type        = string
}

# OS Disk Configuration
variable "os_disk_caching" {
  description = "Caching type for the OS disk (ReadWrite, ReadOnly, None)"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk (Standard_LRS, Premium_LRS, StandardSSD_LRS)"
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB (optional, uses image default if not specified)"
  type        = number
  default     = null
}

# Image Configuration
variable "windows_sku" {
  description = "Windows Server SKU to deploy (2022-Datacenter, 2019-Datacenter, etc.)"
  type        = string
  default     = "2022-Datacenter"
}

variable "windows_version" {
  description = "Windows version to deploy (latest or specific version)"
  type        = string
  default     = "latest"
}

# Additional Configuration
variable "computer_name" {
  description = "Computer name for the VM (defaults to vm_name if not specified)"
  type        = string
  default     = null
}

variable "custom_data" {
  description = "Custom data script to run on VM startup (base64 encoded)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the VM"
  type        = map(string)
  default     = {}
}

# Monitoring and Management
variable "enable_automatic_updates" {
  description = "Enable automatic updates for the VM"
  type        = bool
  default     = true
}

variable "patch_mode" {
  description = "Patch mode for the VM (ImageDefault, AutomaticByPlatform)"
  type        = string
  default     = "AutomaticByPlatform"
}
