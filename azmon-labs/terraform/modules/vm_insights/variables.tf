variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "workspace_id" {
  description = "Resource ID of the Log Analytics workspace"
  type        = string
}

variable "workspace_key" {
  description = "Primary key of the Log Analytics workspace (not needed for modern approach)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "windows_vm_id" {
  description = "Resource ID of the Windows VM"
  type        = string
  default     = null
}

variable "windows_vm_name" {
  description = "Name of the Windows VM"
  type        = string
  default     = null
}

variable "redhat_vm_id" {
  description = "Resource ID of the RedHat VM"
  type        = string
  default     = null
}

variable "redhat_vm_name" {
  description = "Name of the RedHat VM"
  type        = string
  default     = null
}

variable "ubuntu_vm_id" {
  description = "Resource ID of the Ubuntu VM"
  type        = string
  default     = null
}

variable "ubuntu_vm_name" {
  description = "Name of the Ubuntu VM"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
