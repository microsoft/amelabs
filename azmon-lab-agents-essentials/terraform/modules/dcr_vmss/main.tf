# dcr/main.tf
resource "azurerm_monitor_data_collection_rule" "dcr_vmss" {
  name                = "dcr-tf-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name

  data_sources {
    performance_counter {
      name                          = "basic-performance-counters"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\Memory\\Available MBytes",
        "\\Network Interface(*)\\Bytes Total/sec"
      ]
    }

    windows_event_log {
      name    = "basic-windows-events"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }
  }

  destinations {
    log_analytics {
      name                  = "law-destination"
      workspace_resource_id = var.workspace_id
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["law-destination"]
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["law-destination"]
  }

  tags = {
    Environment = "Lab"
    Purpose     = "Data Collection"
  }
}

resource "azurerm_monitor_data_collection_rule_association" "assoc" {
  name                    = "vmss-dcr-association"
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr_vmss.id
  target_resource_id      = var.target_resource_id
  description             = "Association for VMSS DCR"
}