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

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = null
}

variable "ampls_subnet_id" {
  description = "ID of the subnet where AMPLS private endpoint will be deployed"
  type        = string
}

variable "hub_vnet_id" {
  description = "ID of the hub virtual network"
  type        = string
}

variable "windows_spoke_vnet_id" {
  description = "ID of the Windows spoke virtual network"
  type        = string
}

variable "ubuntu_spoke_vnet_id" {
  description = "ID of the Ubuntu spoke virtual network"
  type        = string
}

variable "appservice_spoke_vnet_id" {
  description = "ID of the App Service spoke virtual network"
  type        = string
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

variable "perf_counter_specifiers" {
  description = "List of performance counter specifiers to collect"
  type        = list(string)
  default = [
    "\\Processor Information(_Total)\\% Processor Time",
    "\\Memory\\% Committed Bytes In Use",
    "\\LogicalDisk(C:)\\% Free Space",
    "\\PhysicalDisk(_Total)\\Avg. Disk Queue Length",
    "\\Network Interface(*)\\Bytes Total/sec"
  ]
}

variable "windows_event_log_xpath_queries" {
  description = "XPath queries for Windows Event Log collection"
  type        = list(string)
  default = [
    "Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]",
    "Security!*[System[(band(Keywords,13510798882111488))]]",
    "System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]"
  ]
}

variable "syslog_facility_names" {
  description = "List of syslog facility names to collect"
  type        = list(string)
  default = [
    "auth",
    "authpriv",
    "cron",
    "daemon",
    "mark",
    "kern",
    "local0",
    "local1",
    "local2",
    "local3",
    "local4",
    "local5",
    "local6",
    "local7",
    "lpr",
    "mail",
    "news",
    "syslog",
    "user",
    "uucp"
  ]
}

variable "syslog_log_levels" {
  description = "List of syslog log levels to collect"
  type        = list(string)
  default = [
    "Debug",
    "Info",
    "Notice",
    "Warning",
    "Error",
    "Critical",
    "Alert",
    "Emergency"
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
