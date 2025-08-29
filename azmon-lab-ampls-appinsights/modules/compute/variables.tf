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

variable "windows_vm_subnet_id" {
  description = "ID of the subnet where Windows VM will be deployed"
  type        = string
}

variable "ubuntu_vm_subnet_id" {
  description = "ID of the subnet where Ubuntu VM will be deployed"
  type        = string
}

variable "data_collection_rule_id" {
  description = "ID of the data collection rule to associate with Windows VM"
  type        = string
}

variable "ubuntu_data_collection_rule_id" {
  description = "ID of the data collection rule to associate with Ubuntu VM"
  type        = string
}

variable "data_collection_endpoint_id" {
  description = "ID of the data collection endpoint to associate with VMs"
  type        = string
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for VMs (if not provided, a random password will be generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_B1s"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for OS disks"
  type        = string
  default     = "Standard_LRS"  # Use Standard for B1s VMs
}

variable "enable_public_ips" {
  description = "Whether to create public IPs for VMs (for initial access)"
  type        = bool
  default     = true
}

variable "windows_vm_image" {
  description = "Windows VM image configuration"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

variable "ubuntu_vm_image" {
  description = "Ubuntu VM image configuration"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Auto-shutdown variables
variable "enable_autoshutdown" {
  description = "Whether to enable auto-shutdown for VMs"
  type        = bool
  default     = true
}

variable "autoshutdown_time" {
  description = "Time to shutdown VMs daily (24-hour format, e.g., '1900' for 7:00 PM)"
  type        = string
  default     = "1900"
}

variable "autoshutdown_timezone" {
  description = "Timezone for auto-shutdown schedule"
  type        = string
  default     = "UTC"
}

variable "autoshutdown_notification_enabled" {
  description = "Whether to enable notifications before auto-shutdown"
  type        = bool
  default     = false
}

variable "autoshutdown_notification_time_minutes" {
  description = "Time in minutes before shutdown to send notification"
  type        = number
  default     = 15
}

variable "autoshutdown_notification_email" {
  description = "Email address to send shutdown notifications to"
  type        = string
  default     = ""
}

variable "application_insights_connection_string" {
  description = "Application Insights connection string for the .NET app"
  type        = string
  sensitive   = true
}
