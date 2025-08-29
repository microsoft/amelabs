resource "azurerm_service_plan" "plan" {
  name                = "asp-${var.prefix}-linux"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.plan_sku
  tags                = var.tags
}

locals {
  dotnet_name = coalesce(var.dotnet_app_name, "app-${var.prefix}-dotnet")
  java_name   = coalesce(var.java_app_name,   "app-${var.prefix}-java")
  node_name   = coalesce(var.node_app_name,   "app-${var.prefix}-node")
}

# ----------------- .NET 9 -----------------
resource "azurerm_linux_web_app" "dotnet" {
  name                = local.dotnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  identity { type = "SystemAssigned" }

  site_config {
    application_stack { dotnet_version = var.dotnet_version }
    always_on            = true
    ftps_state           = "Disabled"
    minimum_tls_version  = "1.2"
    vnet_route_all_enabled = true
  }

  virtual_network_subnet_id = var.integration_subnet_id

  app_settings = {
    "WEBSITE_DNS_SERVER"     = "168.63.129.16"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = coalesce(var.appinsights_connection_string, "")
    "XDT_MicrosoftApplicationInsights_Mode" = "Recommended"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "XDT_MicrosoftApplicationInsights_PreemptSdk" = "disabled"
  }

  https_only = true
  tags       = var.tags
}

# ----------------- Java 21 (Java SE) -----------------
resource "azurerm_linux_web_app" "java" {
  name                = local.java_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  identity { type = "SystemAssigned" }

  site_config {
    application_stack {
      java_server         = var.java_server
      java_server_version = var.java_server_version
      java_version        = var.java_version
    }
    always_on            = true
    ftps_state           = "Disabled"
    minimum_tls_version  = "1.2"
    vnet_route_all_enabled = true
   
    app_command_line     = var.java_app_command_line
  }

  virtual_network_subnet_id = var.integration_subnet_id

  app_settings = {
    "WEBSITE_DNS_SERVER"                 = "168.63.129.16"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = coalesce(var.appinsights_connection_string, "")
    "XDT_MicrosoftApplicationInsights_Mode" = "Recommended"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "XDT_MicrosoftApplicationInsights_PreemptSdk" = "disabled"
    "SERVER_PORT" = "$PORT"
  }

  https_only = true
  tags       = var.tags
}

# ----------------- Node.js 20 -----------------
resource "azurerm_linux_web_app" "node" {
  name                = local.node_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  identity { type = "SystemAssigned" }

  site_config {
    application_stack {
      node_version = var.node_version
    }
    always_on            = true
    ftps_state           = "Disabled"
    minimum_tls_version  = "1.2"
    vnet_route_all_enabled = true
   
    app_command_line     = var.node_app_command_line
  }

  virtual_network_subnet_id = var.integration_subnet_id

  app_settings = {
    "WEBSITE_DNS_SERVER"                 = "168.63.129.16"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = coalesce(var.appinsights_connection_string, "")
    "XDT_MicrosoftApplicationInsights_Mode" = "Recommended"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "XDT_MicrosoftApplicationInsights_PreemptSdk" = "disabled"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~${var.node_version}"
  }

  https_only = true
  tags       = var.tags
}


# ------------- Diagnostics -> LAW -------------
resource "azurerm_monitor_diagnostic_setting" "dotnet_to_law" {
  name                           = "diag-${local.dotnet_name}"
  target_resource_id             = azurerm_linux_web_app.dotnet.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log { category = "AppServiceHTTPLogs" }
  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServicePlatformLogs" }
  metric      { category = "AllMetrics" }
}

resource "azurerm_monitor_diagnostic_setting" "java_to_law" {
  name                           = "diag-${local.java_name}"
  target_resource_id             = azurerm_linux_web_app.java.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log { category = "AppServiceHTTPLogs" }
  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServicePlatformLogs" }
  metric      { category = "AllMetrics" }
}

resource "azurerm_monitor_diagnostic_setting" "node_to_law" {
  name                           = "diag-${local.node_name}"
  target_resource_id             = azurerm_linux_web_app.node.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log { category = "AppServiceHTTPLogs" }
  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServicePlatformLogs" }
  metric      { category = "AllMetrics" }
}
