# vmss_windows/variables.tf
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "backend_pool_id" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "vmss_name" {
  type    = string
  default = "vmss-tjf"
}

variable "admin_username" {
  description = "Admin username for the VMSS instances"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VMSS instances"
  type        = string
  sensitive   = true
  # No default - will be provided via terraform.tfvars
}
