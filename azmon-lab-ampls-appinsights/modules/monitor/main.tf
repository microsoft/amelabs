# Monitor Module - Log Analytics, AMPLS, Private Endpoints, and DNS

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                       = var.log_analytics_workspace_name != null ? var.log_analytics_workspace_name : "${var.prefix}-law"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku                        = var.log_analytics_sku
  retention_in_days          = var.log_analytics_retention_days
  internet_ingestion_enabled = false  # This enforces private link only
  internet_query_enabled     = true

  tags = var.tags
}

# Application Insights Instance
resource "azurerm_application_insights" "main" {
  name                = "${var.prefix}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  
  # Connect to the same Log Analytics Workspace
  sampling_percentage = 100

  tags = var.tags
}

# Azure Monitor Private Link Scope (AMPLS)
resource "azurerm_monitor_private_link_scope" "main" {
  name                = "${var.prefix}-ampls"
  resource_group_name = var.resource_group_name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "PrivateOnly"

  tags = var.tags
}

# Associate Log Analytics Workspace with AMPLS
resource "azurerm_monitor_private_link_scoped_service" "law" {
  name                = "${var.prefix}-law-scoped-service"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.main.name
  linked_resource_id  = azurerm_log_analytics_workspace.main.id
}

# Associate Application Insights with AMPLS
resource "azurerm_monitor_private_link_scoped_service" "appinsights" {
  name                = "${var.prefix}-appinsights-scoped-service"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.main.name
  linked_resource_id  = azurerm_application_insights.main.id
}

# Private DNS Zones for Azure Monitor
resource "azurerm_private_dns_zone" "monitor" {
  name                = "privatelink.monitor.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "oms" {
  name                = "privatelink.oms.opinsights.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "ods" {
  name                = "privatelink.ods.opinsights.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "agentsvc" {
  name                = "privatelink.agentsvc.azure-automation.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Private Endpoint for AMPLS
resource "azurerm_private_endpoint" "ampls" {
  name                = "${var.prefix}-ampls-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.ampls_subnet_id

  private_service_connection {
    name                           = "${var.prefix}-ampls-psc"
    private_connection_resource_id = azurerm_monitor_private_link_scope.main.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.monitor.id,
      azurerm_private_dns_zone.oms.id,
      azurerm_private_dns_zone.ods.id,
      azurerm_private_dns_zone.agentsvc.id,
      azurerm_private_dns_zone.blob.id
    ]
  }

  depends_on = [
    azurerm_private_dns_zone.monitor,
    azurerm_private_dns_zone.oms,
    azurerm_private_dns_zone.ods,
    azurerm_private_dns_zone.agentsvc,
    azurerm_private_dns_zone.blob,
    azurerm_monitor_private_link_scope.main,
    azurerm_monitor_private_link_scoped_service.law,
    azurerm_monitor_private_link_scoped_service.appinsights,
    azurerm_monitor_private_link_scoped_service.dce,
    azurerm_private_dns_zone_virtual_network_link.monitor_hub,
    azurerm_private_dns_zone_virtual_network_link.monitor_windows_spoke,
    azurerm_private_dns_zone_virtual_network_link.monitor_ubuntu_spoke,
    azurerm_private_dns_zone_virtual_network_link.monitor_appservice_spoke,
    azurerm_private_dns_zone_virtual_network_link.oms_hub,
    azurerm_private_dns_zone_virtual_network_link.oms_windows_spoke,
    azurerm_private_dns_zone_virtual_network_link.oms_ubuntu_spoke,
    azurerm_private_dns_zone_virtual_network_link.oms_appservice_spoke,
    azurerm_private_dns_zone_virtual_network_link.ods_hub,
    azurerm_private_dns_zone_virtual_network_link.ods_windows_spoke,
    azurerm_private_dns_zone_virtual_network_link.ods_ubuntu_spoke,
    azurerm_private_dns_zone_virtual_network_link.ods_appservice_spoke,
    azurerm_private_dns_zone_virtual_network_link.agentsvc_hub,
    azurerm_private_dns_zone_virtual_network_link.agentsvc_windows_spoke,
    azurerm_private_dns_zone_virtual_network_link.agentsvc_ubuntu_spoke,
    azurerm_private_dns_zone_virtual_network_link.agentsvc_appservice_spoke,
    azurerm_private_dns_zone_virtual_network_link.blob_hub,
    azurerm_private_dns_zone_virtual_network_link.blob_windows_spoke,
    azurerm_private_dns_zone_virtual_network_link.blob_ubuntu_spoke,
    azurerm_private_dns_zone_virtual_network_link.blob_appservice_spoke
  ]

  tags = var.tags
}

# Link Private DNS Zones to Hub VNet
resource "azurerm_private_dns_zone_virtual_network_link" "monitor_hub" {
  name                  = "hub-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.monitor.name
  virtual_network_id    = var.hub_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.monitor
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "oms_hub" {
  name                  = "hub-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.oms.name
  virtual_network_id    = var.hub_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.oms
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ods_hub" {
  name                  = "hub-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ods.name
  virtual_network_id    = var.hub_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.ods
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc_hub" {
  name                  = "hub-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.agentsvc.name
  virtual_network_id    = var.hub_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.agentsvc
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_hub" {
  name                  = "hub-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = var.hub_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.blob
  ]
  
  tags = var.tags
}

# Link Private DNS Zones to Windows Spoke VNet
resource "azurerm_private_dns_zone_virtual_network_link" "monitor_windows_spoke" {
  name                  = "windows-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.monitor.name
  virtual_network_id    = var.windows_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.monitor
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "oms_windows_spoke" {
  name                  = "windows-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.oms.name
  virtual_network_id    = var.windows_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.oms
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ods_windows_spoke" {
  name                  = "windows-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ods.name
  virtual_network_id    = var.windows_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.ods
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc_windows_spoke" {
  name                  = "windows-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.agentsvc.name
  virtual_network_id    = var.windows_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.agentsvc
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_windows_spoke" {
  name                  = "windows-spoke-link"
  resource_group_name   = var.resource_group_name  
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = var.windows_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.blob
  ]
  
  tags = var.tags
}

# Link Private DNS Zones to Ubuntu Spoke VNet
resource "azurerm_private_dns_zone_virtual_network_link" "monitor_ubuntu_spoke" {
  name                  = "ubuntu-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.monitor.name
  virtual_network_id    = var.ubuntu_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.monitor
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "oms_ubuntu_spoke" {
  name                  = "ubuntu-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.oms.name
  virtual_network_id    = var.ubuntu_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.oms
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ods_ubuntu_spoke" {
  name                  = "ubuntu-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ods.name
  virtual_network_id    = var.ubuntu_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.ods
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc_ubuntu_spoke" {
  name                  = "ubuntu-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.agentsvc.name
  virtual_network_id    = var.ubuntu_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.agentsvc
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_ubuntu_spoke" {
  name                  = "ubuntu-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = var.ubuntu_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.blob
  ]
  
  tags = var.tags
}

# Link Private DNS Zones to App Service Spoke VNet
resource "azurerm_private_dns_zone_virtual_network_link" "monitor_appservice_spoke" {
  name                  = "appservice-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.monitor.name
  virtual_network_id    = var.appservice_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.monitor
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "oms_appservice_spoke" {
  name                  = "appservice-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.oms.name
  virtual_network_id    = var.appservice_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.oms
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ods_appservice_spoke" {
  name                  = "appservice-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ods.name
  virtual_network_id    = var.appservice_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.ods
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc_appservice_spoke" {
  name                  = "appservice-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.agentsvc.name
  virtual_network_id    = var.appservice_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.agentsvc
  ]
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_appservice_spoke" {
  name                  = "appservice-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = var.appservice_spoke_vnet_id
  
  depends_on = [
    azurerm_private_dns_zone.blob
  ]
  
  tags = var.tags
}

# Data Collection Endpoint for Azure Monitor Agent (required for AMPLS)
resource "azurerm_monitor_data_collection_endpoint" "main" {
  name                          = "${var.prefix}-dce"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  public_network_access_enabled = false

  tags = var.tags
}

# Associate Data Collection Endpoint with AMPLS
resource "azurerm_monitor_private_link_scoped_service" "dce" {
  name                = "${var.prefix}-dce-scoped-service"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.main.name
  linked_resource_id  = azurerm_monitor_data_collection_endpoint.main.id

  depends_on = [
    azurerm_monitor_private_link_scope.main,
    azurerm_monitor_data_collection_endpoint.main
  ]
}

# Data Collection Rule for Azure Monitor Agent
resource "azurerm_monitor_data_collection_rule" "main" {
  name                        = "${var.prefix}-dcr"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.main.id

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "destination-log"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["destination-log"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor Information(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space"
      ]
      name = "perfCounterDataSource"
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.main,
    azurerm_monitor_data_collection_endpoint.main,
    azurerm_monitor_private_link_scoped_service.dce
  ]

  tags = var.tags
}

# Data Collection Rule for Ubuntu VM (Syslog)
resource "azurerm_monitor_data_collection_rule" "ubuntu" {
  name                        = "${var.prefix}-dcr-ubuntu"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  kind                        = "Linux"
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.main.id

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "destination-log"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["destination-log"]
  }

  data_sources {
    syslog {
      streams        = ["Microsoft-Syslog"]
      facility_names = ["user", "mail", "daemon", "auth", "syslog", "lpr", "news", "uucp", "ftp", "ntp", "audit", "alert", "mark", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7"]
      log_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
      name           = "syslogDataSource"
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.main,
    azurerm_monitor_data_collection_endpoint.main,
    azurerm_monitor_private_link_scoped_service.dce,
    azurerm_monitor_private_link_scoped_service.workspace
  ]

  tags = var.tags
}
