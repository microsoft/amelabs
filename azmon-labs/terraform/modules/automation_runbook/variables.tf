# automation_runbook/variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "automation_account_name" {
  description = "Name of the Azure Automation Account"
  type        = string
  default     = "aa-vmss-autoshutdown"
}

variable "vmss_name" {
  description = "Name of the Virtual Machine Scale Set to shutdown"
  type        = string
}

variable "user_timezone_hour" {
  description = "Hour in 24-hour format (HH:MM) when to shutdown VMSS in user's timezone converted to UTC"
  type        = string
  validation {
    condition     = can(regex("^[0-2][0-9]:[0-5][0-9]$", var.user_timezone_hour))
    error_message = "The user_timezone_hour must be in HH:MM format (e.g., '19:00')."
  }
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "aks_name" {
  description = "Name of the AKS cluster to shutdown"
  type        = string
}
