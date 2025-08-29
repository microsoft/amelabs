variable "workspace_name" {
  type        = string
  description = "Name of the Log Analytics Workspace"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "workspace_sku" {
  type        = string
  description = "SKU for the workspace"
  default     = "PerGB2018"
}

variable "retention_in_days" {
  type        = number
  description = "Retention period for logs (in days)"
  default     = 30
}
