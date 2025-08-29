output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "ampls_id" {
  description = "ID of the Azure Monitor Private Link Scope"
  value       = azurerm_monitor_private_link_scope.main.id
}

output "ampls_name" {
  description = "Name of the Azure Monitor Private Link Scope"
  value       = azurerm_monitor_private_link_scope.main.name
}

output "private_endpoint_ip" {
  description = "Private IP address of the AMPLS private endpoint"
  value       = azurerm_private_endpoint.ampls.private_service_connection[0].private_ip_address
}

output "data_collection_rule_id" {
  description = "ID of the data collection rule"
  value       = azurerm_monitor_data_collection_rule.main.id
}

output "data_collection_rule_name" {
  description = "Name of the data collection rule"
  value       = azurerm_monitor_data_collection_rule.main.name
}

output "ubuntu_data_collection_rule_id" {
  description = "ID of the Ubuntu data collection rule"
  value       = azurerm_monitor_data_collection_rule.ubuntu.id
}

output "ubuntu_data_collection_rule_name" {
  description = "Name of the Ubuntu data collection rule"
  value       = azurerm_monitor_data_collection_rule.ubuntu.name
}

output "data_collection_endpoint_id" {
  description = "ID of the data collection endpoint"
  value       = azurerm_monitor_data_collection_endpoint.main.id
}

output "data_collection_endpoint_name" {
  description = "Name of the data collection endpoint"
  value       = azurerm_monitor_data_collection_endpoint.main.name
}

output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = azurerm_application_insights.main.id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.main.name
}

output "instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}
