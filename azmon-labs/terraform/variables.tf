variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "workspace_name" {
  description = "Log Analytics Workspace name"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "user_timezone" {
  description = "User's timezone for auto-shutdown configuration"
  type        = string
  default     = "UTC"
}

variable "aks_name" {
  description = "AKS Cluster name"
  type        = string
  default     = "aks-azmon"
}

variable "grafana_name" {
  description = "Managed Grafana name"
  type        = string
  default     = "managed-gf"
}

variable "prom_name" {
  description = "Managed Prometheus name"
  type        = string
  default     = "managed-pm"
}


variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "vmss_subnet"
}


variable "vmss_name" {
  description = "Name of the Virtual Machine Scale Set"
  type        = string
  default     = "vmss-win"  # Short name to avoid any naming issues
}



variable "admin_username" {
  description = "Common admin username for all VMs and VMSS"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Common admin password for all VMs and VMSS"
  type        = string
  sensitive   = true
  # No default - will be provided via terraform.tfvars
}



# Ubuntu VM Configuration
variable "ubuntu_vm_name" {
  description = "Name of the Ubuntu Virtual Machine"
  type        = string
  default     = "vm-ubuntu-lab"
}

variable "ubuntu_vm_size" {
  description = "Size of the Ubuntu VM"
  type        = string
  default     = "Standard_B2s"
}


# Windows VM Configuration
variable "windows_vm_name" {
  description = "Name of the Windows Virtual Machine"
  type        = string
  default     = "vm-windows-lab"
}

variable "windows_vm_size" {
  description = "Size of the Windows VM"
  type        = string
  default     = "Standard_B2s"
}

# Red Hat VM Configuration
variable "redhat_vm_name" {
  description = "Name of the Red Hat Virtual Machine"
  type        = string
  default     = "vm-redhat-lab"
}

variable "redhat_vm_size" {
  description = "Size of the Red Hat VM"
  type        = string
  default     = "Standard_B2s"
}

variable "automation_account_name" {
  description = "Name of the Azure Automation Account for VMSS auto-shutdown"
  type        = string
  default     = "aa-vmss-autoshutdown"
}



