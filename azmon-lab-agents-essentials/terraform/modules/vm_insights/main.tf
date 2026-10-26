# Data Collection Rule for VM Insights (performance counters only)
# Note: Dependency Agent has been deprecated and is no longer used by this lab.
# AMA is installed by each VM module; this module only creates the DCR and the
# DCR-to-VM associations required for VM Insights.
resource "azurerm_monitor_data_collection_rule" "vm_insights" {
  name                = "MSVMI-${var.workspace_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Data Collection Rule for VM Insights (performance counters)"

  destinations {
    log_analytics {
      workspace_resource_id = var.workspace_id
      name                  = "VMInsightsPerf-Logs-Dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["VMInsightsPerf-Logs-Dest"]
  }

  data_sources {
    performance_counter {
      name                          = "VMInsightsPerfCounters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
    }
  }

  tags = var.tags
}

# DCR Association - Windows VM
resource "azurerm_monitor_data_collection_rule_association" "windows_vm" {
  count                   = var.windows_vm_name != null && var.windows_vm_name != "" ? 1 : 0
  name                    = "MSVMI-${var.windows_vm_name}-dcra"
  target_resource_id      = var.windows_vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm_insights.id
  description             = "VM Insights DCR association for Windows VM"
}

# DCR Association - RedHat VM
resource "azurerm_monitor_data_collection_rule_association" "redhat_vm" {
  count                   = var.redhat_vm_name != null && var.redhat_vm_name != "" ? 1 : 0
  name                    = "MSVMI-${var.redhat_vm_name}-dcra"
  target_resource_id      = var.redhat_vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm_insights.id
  description             = "VM Insights DCR association for RedHat VM"
}

# DCR Association - Ubuntu VM
resource "azurerm_monitor_data_collection_rule_association" "ubuntu_vm" {
  count                   = var.ubuntu_vm_name != null && var.ubuntu_vm_name != "" ? 1 : 0
  name                    = "MSVMI-${var.ubuntu_vm_name}-dcra"
  target_resource_id      = var.ubuntu_vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm_insights.id
  description             = "VM Insights DCR association for Ubuntu VM"
}
