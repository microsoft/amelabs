variable "prefix" {
  description = "Prefix for infrastructure resource names"
  type        = string
  default     = "azmon"
}

variable "app_service_prefix" {
  description = "Prefix for App Service names (to avoid conflicts)"
  type        = string
  default     = "azmon"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-azmon-ampls-lab"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "law-azmon-ampls-lab"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "North Europe"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_B2s"  # Supports Gen2, 2 vCPUs, 4GB RAM
}

variable "enable_public_ips" {
  description = "Whether to create public IPs for VMs (for initial access)"
  type        = bool
  default     = true
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

variable "appservice_spoke_vnet_address_space" {
  description = "Address space for the App Service spoke virtual network"
  type        = list(string)
  default     = ["10.3.0.0/16"]
}

variable "appservice_spoke_integration_subnet_address_prefixes" {
  description = "Address prefixes for the App Service integration subnet in App Service spoke VNet"
  type        = list(string)
  default     = ["10.3.1.0/24"]
}

variable "log_analytics_sku" {
  description = "SKU for the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Retention period in days for Log Analytics Workspace"
  type        = number
  default     = 30
}

variable "perf_counter_sampling_frequency" {
  description = "Sampling frequency in seconds for performance counters"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Lab"
    Project     = "Azure Monitor AMPLS"
    Purpose     = "Testing"
  }
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

variable "autoshutdown_notification_email" {
  description = "Email address to send shutdown notifications to (required if notifications enabled)"
  type        = string
  default     = ""
}
