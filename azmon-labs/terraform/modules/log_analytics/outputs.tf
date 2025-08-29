output "workspace_id" {
  description = "The Workspace ID (used for DCR or monitoring agent extensions)"
  value       = azurerm_log_analytics_workspace.law.id
}

output "workspace_name" {
  description = "The name of the workspace"
  value       = azurerm_log_analytics_workspace.law.name
}
